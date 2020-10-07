classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        ADJ; % adjacency matrix
        agents; % network agents
        agentstates; % number of states
        agentinputs; % number of inputs
        A; % adjacency matrix
        F; % network matrix
        T; % times vector
        TX; % Transmissions matrix
        x0; % initial states
        X; % states matrix
        ERROR;
        ERROR_THRESHOLD
        U;
        SIZE; % network size
    end
    properties (Dependent)
        t; % current time instant
        consensus; % consensus boolean
        final_value; % consensus value
    end
    
    methods
        function obj = Network(type, A, B, C, D, X0, ADJ)
            import ConsensusMAS.*;
            % Create the matrices
            obj.SIZE = size(X0, 2);
            obj.x0 = X0;
            obj.agentstates = size(X0, 1);
            obj.agentinputs = size(B, 2);
            obj.ADJ = ADJ;
            obj.F = (eye(obj.SIZE) + diag(sum(ADJ, 2)))^-1 * (eye(obj.SIZE) * ADJ);
            
            % Create the agents
            switch type
                case Implementations.FixedTrigger
                    agents = AgentFixedTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentFixedTrigger(n, A, B, C, D, X0(:,n));
                    end
                case Implementations.GlobalEventTrigger
                    agents = AgentGlobalEventTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentGlobalEventTrigger(n, A, B, C, D, X0(:,n), ADJ);
                    end
                case Implementations.LocalEventTrigger
                    agents = AgentLocalEventTrigger.empty(obj.SIZE, 0);
                    for n = 1:obj.SIZE
                        agents(n) = AgentLocalEventTrigger(n, A, B, C, D, X0(:,n), ADJ);
                    end
                otherwise
                    error("Unrecognised type");
            end
            
            
            % Create the network
            for i = 1:obj.SIZE % row-wise
                for j = 1:obj.SIZE %column-wise
                    weight = obj.ADJ(i, j);
                    if (i~=j && weight ~= 0)
                        agents(j).addReceiver(agents(i), weight);
                    end
                end
            end
            obj.agents = agents;
        end
        
        % Getters and Setters
        function set.t(obj, t)
            obj.T = [obj.T t]; 
        end
        function t = get.t(obj)
            t = obj.T(end); 
        end

        function X = get.X(obj)
           X = zeros(obj.agentstates, length(obj.T), obj.SIZE);
           for agent = obj.agents
               X(:,:,agent.id) = agent.X;
           end
        end
        function U = get.U(obj)
           U = zeros(obj.agentinputs, length(obj.T), obj.SIZE);
           for agent = obj.agents
               U(:,:,agent.id) = agent.U;
           end
        end
        function ERROR = get.ERROR(obj)
           ERROR = zeros(obj.agentstates, length(obj.T), obj.SIZE);
           for agent = obj.agents
               ERROR(:,:,agent.id) = agent.ERROR;
           end
        end
        function ERROR_THRESHOLD = get.ERROR_THRESHOLD(obj)
           ERROR_THRESHOLD = zeros(obj.agentstates, length(obj.T), obj.SIZE);
           for agent = obj.agents
               ERROR_THRESHOLD(:,:,agent.id) = agent.ERROR_THRESHOLD;
           end
        end
        function TX = get.TX(obj)
           TX = zeros(obj.agentstates, length(obj.T), obj.SIZE);
           for agent = obj.agents
               TX(:,:,agent.id) = agent.TX;
           end
        end
        
        
        
        function consensus = get.consensus(obj)
            % Checks whether the network has reached consensus
            import ConsensusMAS.Utils.*;
            consensus = ConsensusReached(obj.x0, [obj.agents.x]); 
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
            import ConsensusMAS.Utils.*;
            import ConsensusMAS.EventTrigger.*;
            
            % Parse the args
            ts = 1;
            mintime = 0;
            maxtime = 100;
            for k = 1:length(varargin)
                if (strcmp(varargin{k},"timestep"))
                    k = k + 1;
                    ts = varargin{k};
                end
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
            
            % Simulate
            while (true)
                
                % Broadcast agents if needed
                for agent = obj.agents
                    agent.check_trigger;
                end
                
                % Have agents save their data
                for agent = obj.agents
                    agent.save
                end
                
                % Step accordingly
                for agent = obj.agents
                    agent.step(ts);
                end 
                
                %{
                if obj.t > 0.2 && obj.t < 0.3
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
                obj.t = obj.t + ts;
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