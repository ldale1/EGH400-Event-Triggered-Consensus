classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        ADJ; % adjacency matrix
        agents; % network agents
        agentstates; % number of states
        A; % adjacency matrix
        F; % network matrix
        T; % times vector
        TX; % Transmissions matrix
    end
    properties (Dependent)
        SIZE; % network size
        t; % current time instant
        tx; % latest transmission
        x0; % initial states
        x; % current states
        X; % states matrix
        consensus; % consensus boolean
        final_value; % consensus value
    end
    
    methods
        function obj = Network(type, A, B, C, D, X0, ADJ)
            import ConsensusMAS.*;
            % Create the matrices
            SIZE = size(X0, 2);
            obj.agentstates = size(X0, 1);
            
            obj.ADJ = ADJ;
            obj.F = (eye(SIZE) + diag(sum(ADJ, 2)))^-1 * (eye(SIZE) * ADJ);
            
            % Create the agents
            switch type
                case Implementations.FixedTrigger
                    agents = AgentFixedTrigger.empty(SIZE, 0);
                    for n = 1:SIZE
                        agents(n) = AgentFixedTrigger(n, A, B, C, D, X0(:,n));
                    end
                case Implementations.GlobalEventTrigger
                    agents = AgentGlobalEventTrigger.empty(SIZE, 0);
                    for n = 1:SIZE
                        agents(n) = AgentGlobalEventTrigger(n, A, B, C, D, X0(:,n), ADJ);
                    end
                otherwise
                    error("Unrecognised type");
            end
            
            
            % Create the network
            for i = 1:SIZE % row-wise
                for j = 1:SIZE %column-wise
                    weight = obj.F(i, j);
                    if (i~=j && weight ~= 0)
                        agents(j).addReceiver(agents(i), weight);
                    end
                end
            end
            obj.agents = agents;
        end
        
        % Getters and Setters
        function set.t(obj, t); obj.T = [obj.T t]; end
        function t = get.t(obj); t = obj.T(end); end
        
        function set.tx(obj, tx)          
            obj.TX = [obj.TX tx];
        end
        function tx = get.tx(obj)
            tx = obj.TX(end); 
        end
        
        function X = get.X(obj)
            % State array getter, there is one z dimension for each agent
            X = zeros(obj.agentstates, length(obj.T), obj.SIZE);
            for agent = obj.agents
                X(:,:,agent.id) = agent.X;
            end
        end
        function x0 = get.x0(obj)
            x0 = obj.X(:,1,:);
        end
        function x = get.x(obj)
            x = obj.X(:,end,:);
        end
        function SIZE = get.SIZE(obj); SIZE = length(obj.agents); end
        function consensus = get.consensus(obj)
            import ConsensusMAS.Utils.*;
            consensus = ConsensusReached(obj.x0, obj.x); 
        end
        function final_value = get.final_value(obj)
            if ~obj.consensus
                error("This network has not reached consensus.");
            else
                final_value = mean(obj.x); 
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
            obj.tx = zeros(obj.agentstates, 1, obj.SIZE);
            
            % Simulate
            while (true)           
                % Step accordingly
                for agent = obj.agents
                    agent.step(ts);
                end 
                
                % Update triggers
                triggers = zeros(obj.agentstates, 1, obj.SIZE);
                for agent = obj.agents
                    triggers(:,:,agent.id) = agent.checktrigger;
                end
                obj.tx = triggers;
                
                % Update time
                obj.t = obj.t + ts;
                
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
        
        % Complex Subplot Figures
        PlotTriggersStates(obj,varargin);
        
        
        function obj = Animate(obj)
            % Create a figure animation and save
            import ConsensusMAS.Utils.*;
            
            % So far this is only two dimensional
            % inputs: agent x rows, steps x columns
            
            % inputs
            x = squeeze(obj.X(1,:,:))';
            y = ones(obj.SIZE, length(obj.T)) .* (1:obj.SIZE)';
            x_tx = squeeze(obj.TX(1,:,:))';
            y_tx = ones(obj.SIZE, length(obj.T)) .* (1:obj.SIZE)';
            
            % Update if there was more than a single state
            if (obj.agentstates > 1)
                y = squeeze(obj.X(2,:,:))';
                y_tx = squeeze(obj.TX(2,:,:))';
            end
            
            % Create movie
            MovieMaker(obj.T, x, y, x_tx, y_tx);
        end
    end
end