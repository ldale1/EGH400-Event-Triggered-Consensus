classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        ADJ; % adjacency matrix
        SIZE; % network size
        agents; % network agents
        agentstates; % number of states
        agentinputs; % number of inputs
        
        A; % adjacency matrix
        F; % network matrix
        
        ts;
        T; % times vector
        TX; % Transmissions matrix
        
        x0; % initial states
        X; % states matrix
        U; % inputs matrix
        
        ERROR; % error matrix
        ERROR_THRESHOLD % error threshold matrix
    end
    properties (Dependent)
        t; % current time instant
        consensus; % consensus boolean
        final_value; % consensus value
    end
    
    methods
        function obj = Network(type, A, B, C, D, X0, ADJ, T)
            % Network constructor
            import ConsensusMAS.*;
            % Create the matrices
            obj.SIZE = size(X0, 2);
            obj.x0 = X0;
            obj.agentstates = size(X0, 1);
            obj.agentinputs = size(B, 2);
            obj.ADJ = ADJ;
            obj.ts = T;
            
            % Frobenius discrete time RS matrix
            I = eye(obj.SIZE);
            DEG = diag(sum(ADJ, 2));
            L = DEG - ADJ;
            F = (I + DEG)^-1 * (I + ADJ);

            % Create the agents
            switch type
                case Implementations.FixedTrigger
                    agents = AgentFixedTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentFixedTrigger(n, A, B, C, D, T, X0(:,n), T);
                    end
                case Implementations.GlobalEventTrigger
                    agents = AgentGlobalEventTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentGlobalEventTrigger(n, A, B, C, D, T, X0(:,n), L);
                    end
                case Implementations.LocalEventTrigger
                    agents = AgentLocalEventTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentLocalEventTrigger(n, A, B, C, D, T, X0(:,n), L);
                    end
                otherwise
                    error("Unrecognised type");
            end

            % Create the network
            for i = 1:obj.SIZE % row-wise
                for j = 1:obj.SIZE %column-wise
                    weight = F(i, j);
                    if (i~=j && weight ~= 0)
                        agents(j).addReceiver(agents(i), weight);
                    end
                end
            end
            
            obj.agents = agents;
        end
        
        function set.t(obj, t)
            % Setting time udpates times vector
            obj.T = [obj.T t]; 
        end
        function t = get.t(obj)
            % Get latest time
            t = obj.T(end); 
        end
        
        function consensus = get.consensus(obj)
            % Checks whether the network has reached consensus
            u = ones(obj.agentinputs, 1, obj.SIZE);
            for agent = obj.agents
                u(:,:,agent.id) = agent.u;
            end
            consensus = all(all(abs(u) < 1e-2));
        end
        function final_value = get.final_value(obj)
            % Gets the current average of current states
            if ~obj.consensus
                error("This network has not reached consensus.");
            else
                final_value = mean([obj.agents.x]); 
            end
        end
       
        
        function obj = Simulate(obj, varargin)
            % Parse the args
            mintime = 0;
            maxtime = 1e5;
            for k = 1:length(varargin)
                if (strcmp(varargin{k},"mintime"))
                    k = k + 1;
                    mintime = varargin{k};
                end
                if (strcmp(varargin{k},"maxtime"))
                    k = k + 1;
                    maxtime = varargin{k};
                end
            end
            
            % Begin
            % Agents are initialised with
            % x = x0, u = 0, xhat = 0            
            obj.t = 0;
            
            for agent = obj.agents
                agent.sample();
            end
            
            for agent = obj.agents
                agent.broadcast();
            end
            
            for agent = obj.agents
                agent.setinput();
            end
            
            % Have agents save their data
            for agent = obj.agents
                agent.save();
            end
            
            % Step accordingly
            for agent = obj.agents
                agent.step();
            end 
            
            % Simulate
            while (true) 
                obj.t = obj.t + obj.ts;
                
                % Broadcast agents if needed
                for agent = obj.agents
                    agent.check_trigger();
                end
                
                % Have agents save their data
                for agent = obj.agents
                    agent.save();
                end
                
                % Step accordingly
                for agent = obj.agents
                    agent.step();
                end 
                
                
                %{
                if obj.t > 150 && obj.t < 160
                    fprintf("STEP:\n")
                    disp(obj.t)
                    disp(squeeze([obj.agents.tx]))
                    disp(squeeze([obj.agents.xhat]))
                    disp(squeeze([obj.agents.u]))
                    fprintf("\n")
                end
                %}
                
     
                % Check the exit conditions                
                finished = (round(obj.t - mintime, 4) >= 0) && obj.consensus;
                if (finished || obj.t > maxtime)
                    break;
                end
            end
        end
        
        
        % Basic Figures
        PlotEigs(obj, varargin);
        PlotGraph(obj, varargin);
        PlotInputs(obj, varargin);
        PlotStates(obj, varargin);
        PlotTriggers(obj, varargin);
        PlotErrors(obj, varargin);
        Plot3(obj, vargargin)
        
        % Complex Subplot Figures
        PlotTriggersStates(obj,varargin);
        PlotTriggersInputs(obj, varargin);
        
        % Animation
        Animate(obj, varargin);
    end
end