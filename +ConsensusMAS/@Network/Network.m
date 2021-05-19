classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        type;
        TOPS; % Network topologies vector
        SIZE; % network size
        agents; % network agents
        agentstates;
        agentinputs;
        agent_generator;
        
        wind_model; % disturbance
        wind_disturbance = [];
        
        T; % times vector
        ts; % time steps
    end
    properties (Dependent)
        ADJ; % adjacency matrix
        t; % current time instant
    end
    
    methods (Static)
        function gen = AgentGenerator(type, states,  Af, Bf, ...
                            controller, controller_struct, ...
                            numstates,  numinputs,  ...
                            ts, wind_input)
            % Curry agent creation for dynamic simulation
            import ConsensusMAS.*;
            switch type
                case ImplementationsEnum.FixedTrigger
                    gen = @(n, x, delta, sp) ...
                        AgentFixedTrigger( ... 
                            n, states,  Af, Bf, ...
                            controller, controller_struct, ...
                            numstates,  numinputs,  ...
                            x, delta, sp,   ...
                            ts, wind_input);
                
                case ImplementationsEnum.GlobalEventTrigger
                    gen = @(n, x, delta, sp) ...
                        AgentGlobalEventTrigger( ... 
                            n, states,  Af, Bf, ...
                            controller, controller_struct, ...
                            numstates,  numinputs,  ...
                            x, delta, sp,   ...
                            ts, wind_input);
                    
                case ImplementationsEnum.ETSMC
                    gen = @(n, x, delta, sp) ...
                        AgentSMC( ... 
                            n, states,  Af, Bf, ...
                            controller, controller_struct, ...
                            numstates,  numinputs,  ...
                            x, delta, sp,   ...
                            ts, wind_input);
                    
                otherwise
                    error("Unrecognised type");
            end
        end
    end
    
    methods
        function obj = Network(type, states, Af, Bf, controller, controller_struct, ...
            numstates, numinputs, X0, delta, setpoint, ts, wind_input, wind_model_enum)
        
            % Network constructor
            import ConsensusMAS.*;
            import ConsensusMAS.Utils.*;
            
            % Store
            obj.type = type;
            obj.SIZE = size(X0, 2);
            obj.t = 0;
            obj.ts = ts;
            obj.agentstates = numstates;
            obj.agentinputs = numinputs;
            
            % Generate agents
            obj.agent_generator = Network.AgentGenerator(...
                type, states,  Af, Bf, ...
                controller, controller_struct, ...
                numstates,  numinputs,  ...
                ts, wind_input);
            
            obj.agents = arrayfun(@(x) ...
                obj.agent_generator(x, X0(:,x),  delta(x),  setpoint(x)), ...
                1:obj.SIZE);
            
            % Save their initial values
            for agent = obj.agents
                agent.save()
            end
            
            % Wind model
            obj.wind_model = Wind( ...
                wind_model_enum,  ...
                27.47, ... % lat brisbane
                153.02, ... % long brisbane
                1000, ... %altitude
                0, ... % start time
                ts ...
            );
        end
        
        
        function set.t(obj, t)
            % Setting time udpates times vector
            obj.T = [obj.T t]; 
        end
        function t = get.t(obj)
            % Get latest time
            t = obj.T(end); 
        end
        
        function set.ADJ(obj, ADJ)
            % Create the network
            import ConsensusMAS.*;
            import ConsensusMAS.Utils.*;

            % Frobenius discrete time RS matrix
            L = GraphLaplacian(ADJ);
            F = GraphFrobenius(ADJ);
            
            %{
            % Create new ones
            if (obj.type == ImplementationsEnum.LocalEventTrigger)
                F = [4 0 0 1 3 2;
                     5 5 0 0 0 0;
                     3 2 5 0 0 0;
                     5 0 0 5 0 0;
                     0 0 0 4 4 2;
                     0 0 0 0 3 7]/10;
            end
            %}
            
            % Cleanse connections
            for agent = obj.agents
                agent.leaders = [];
                agent.followers = [];
                agent.transmissions_rx = [];
                
                switch obj.type                        
                    case ImplementationsEnum.GlobalEventTrigger
                        agent.L = L;
                    case ImplementationsEnum.LocalEventTrigger
                        agent.F = F;
                    otherwise
                        %
                end
            end
            
            for i = 1:obj.SIZE % row-wise
                for j = 1:obj.SIZE %column-wise
                    weight = F(i, j);
                    if (i~=j && weight ~= 0)
                        obj.agents(j).addReceiver(obj.agents(i), weight);
                    end
                end
            end
            
            % This isn't saved !
            % TODO: This be wrong
            for agent = obj.agents
                agent.tx = ones(size(agent.x));
                agent.sample()
                agent.broadcast()
            end
            
            for agent = obj.agents
                agent.check_receive()
            end
            
            % Storing topology
            top.t = obj.t;
            top.ADJ = ADJ;
            obj.TOPS = [obj.TOPS top]; 
        end
        
        function ADJ = get.ADJ(obj)
            try
                ADJ = obj.TOPS(end).ADJ; 
            catch
                ADJ = zeros(obj.SIZE);
            end
        end
        
        function consensus = consensus(obj)
            % Checks whether the network has reached consensus
            % If at consensus should not have a control input
            u = ones(obj.agentinputs, 1, obj.SIZE);
            
            for agent = obj.agents
                u(:,:,agent.id) = agent.u;
            end
            consensus = all(all(abs(u) < 1e-2));
        end
        
        function final_value = final_value(obj)
            % Gets the current average of current states
            if ~obj.consensus
                error("This network has not reached consensus.");
            else
                final_value = mean([obj.agents.x]); 
            end
        end
       
        % Simulate network
        Simulate(obj, varargin);
        SimulateDynamic(obj, varargin);
        
        % Graph Figures
        PlotEigs(obj, varargin);
        PlotGraph(obj, varargin);
        
        % Basic Figures
        PlotInputs(obj, varargin);
        PlotStates(obj, varargin);
        PlotTriggers(obj, varargin);
        
        % Complex Subplot Figures
        PlotErrors(obj, varargin);
        PlotErrorsNorm(obj, varargin);
        Plot3(obj, varargin)
        PlotTriggersStates(obj,varargin);
        PlotTriggersInputs(obj, varargin);
        
        % Animation
        Animate(obj, varargin);
    end
    
    methods(Static)
       colors = GetColors(ncolors);
   end
end