classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        agents; % network agents
        F; % network matrix
        T; % times vector
        TRIGGERS; % triggers vectors
    end
    properties (Dependent)
        SIZE; % network size
        t; % current time instant
        x; % current states
        x0; % initial states
        consensus; % consensus boolean
        final_value; % consensus value
        eigenvalues; % network eigenvalues
    end
    
    methods
        function obj = Network(type, A, X0)
            import ConsensusMAS.*;
            % Create the matrices
            SIZE = length(X0);
            obj.F = (eye(SIZE) + diag(sum(A, 2)))^-1 * (eye(SIZE) * A);
            
            % Create the agents
            switch type
                case Implementations.FixedTrigger
                    agents = AgentFixedTrigger.empty(SIZE, 0);
                    for n = 1:SIZE
                        agents(n) = AgentFixedTrigger(n, X0(n));
                    end
                case Implementations.GlobalEventTrigger
                    agents = AgentGlobalEventTrigger.empty(SIZE, 0);
                    for n = 1:SIZE
                        agents(n) = AgentGlobalEventTrigger(n, X0(n));
                    end
                otherwise
                    error("Unrecognised type");
            end
            
            
            % Create the network
            for i = 1:SIZE % row-wise
                for j = 1:SIZE %column-wise
                    weight = obj.F(i, j);
                    if (i~=j && weight ~= 0)
                        agents(j).addReceiver(weight, agents(i));
                    end
                end
            end
            obj.agents = agents;
        end
        
        % Getters and Setters
        function set.t(obj, t); obj.T = [obj.T t]; end
        function t = get.t(obj); t = obj.T(end); end
        function x0 = get.x0(obj)
            x0 = zeros(obj.SIZE, 1);
            for i = 1:obj.SIZE
                x0(i) = obj.agents(i).X(1);
            end
        end
        function x = get.x(obj)
            x = zeros(obj.SIZE, 1);
            for i = 1:obj.SIZE
                x(i) = obj.agents(i).X(end);
            end
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
        function eigenvalues = get.eigenvalues(obj); eigenvalues = eig(obj.F); end
       
        
        function obj = Simulate(obj, varargin)
            import ConsensusMAS.Utils.*;
            import ConsensusMAS.EventTrigger.*;
            
            % Parse the args
            ts = 1;
            mintime = 0;
            maxsteps = 1e5-1;
            for k = 1:length(varargin)
                if (strcmp(varargin{k},"timestep"))
                    k = k + 1;
                    ts = varargin{k};
                end
                if (strcmp(varargin{k},"mintime"))
                    k = k + 1;
                    mintime = varargin{k};
                end
                if (strcmp(varargin{k},"maxsteps"))
                    k = k + 1;
                    maxsteps = varargin{k};
                end
            end
            
            % Begin
            obj.t = 0;
            steps = 0;
            
            % Calculate all inptus
            for agent = obj.agents
                agent.setinput;
            end
            
            % Simulate
            while (true)               
                % Step accordingly
                for agent = obj.agents
                    agent.step(ts);
                end 
                
                for agent = obj.agents
                    if (agent.trigger)
                        obj.TRIGGERS = [obj.TRIGGERS struct('id', agent.id, 't', obj.t)];
                        agent.broadcast;
                    end
                end
                obj.t = obj.t + ts;
                
                % Check the exit conditions
                steps = steps + 1;
                if (round(obj.t - mintime, 6) >= 0 && (steps >= maxsteps || obj.consensus))
                    break;
                end
            end
        end
        
        % Basic Figures
        PlotEigs(obj,varargin);
        PlotGraph(obj,varargin);
        PlotInputs(obj,varargin);
        PlotStates(obj,varargin);
        PlotTriggers(obj,varargin);
        
        % Complex Subplot Figures
        PlotGraphStates(obj,varargin);
        PlotTriggersStates(obj,varargin);
    end
end