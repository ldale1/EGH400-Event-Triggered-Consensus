classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        type;
        TOPS; % Network topologies vector
        SIZE; % network size
        agents; % network agents
        virtual_agents;
        agentstates;
        agentinputs;
        agent_generator;
        
        T; % times vector
        ts; % time steps
        
        wind;
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
                            n, states,  0, 0, ...
                            controller, controller_struct, ...
                            numstates,  numinputs,  ...
                            x, 0, 0,   ...
                            ts, wind_input);
                                       
                otherwise
                    error("Unrecognised type");
            end
        end
    end
    
    methods
        function obj = Network(type, states, Af, Bf, controller, controller_struct, ...
            numstates, numinputs, X0, delta, setpoint, ts, wind_input)
        
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
            
            global wind
            obj.wind = wind;
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
        
        function add_leader(obj, states, numstates, x0)
            %{
            Agent(id, states, Af, Bf, controller_enum, cs, ...
                  numstates, numinputs, x0, delta, setpoint, ...
                  CLK, wind_states)
            %}
            import ConsensusMAS.VirtualLeader;
            
            virtual_leader = VirtualLeader(99999, states, NaN,  NaN, NaN,  NaN, ...
                 numstates,  1, x0,  zeros(numstates, 1),  NaN, ...
                 obj.ts,  []);
            virtual_leader.save(); 
            
            for agent = obj.agents
                %virtual_leader.addReceiver(agent, 1/(length(obj.agents)));
                virtual_leader.addReceiver(agent, 1);
            end
             
            obj.virtual_agents = [obj.virtual_agents virtual_leader];
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
       
        function assign_formation(obj)
            %{
            X = [obj.agents.x];
            
            dx_avg = mean(X(2,:));
            dy_avg = mean(X(4,:));
            theta = atan2(dy_avg, dx_avg);
          
            
            x_base = @(id) 10 * abs(id - (obj.SIZE + 1)/2);
            y_base = @(id) 10 * ((obj.SIZE + 1)/2 - id);
            
            
            x = @(id) x_base(id)*cos(theta) - y_base(id)*sin(theta);
            y = @(id) x_base(id)*sin(theta) + y_base(id)*cos(theta);
            
            
            ref = @(id) [x(id); 0; y(id); 0; 0; 0];
            
            for agent = obj.agents
                agent.delta = ref(agent.id);
            end
            %}
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
       
       
       function NetworkCompare(network_map)
           figure(), hold on;
           for key = network_map.keys
              network = network_map(cell2mat(key));
              
              Xs = zeros(network.SIZE, length(network.T));
              for ii = 1:network.SIZE
                  Xs(ii,:) = sum(network.agents(ii).ERROR.^2);
                  Xs(ii,1) = NaN;
              end

                % 
              actual = sum(Xs);
              plot(network.T, actual/max(actual), "DisplayName", cell2mat(key));
           end
          
           
           legend()
       end
       
   end
end