classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    % What about tx and rx in same step
    
    properties
        id; % Agent ID number
        A;
        B;
        C;
        D;
        K;
        
        leaders; % Leading agents
        followers; % Following agents
        
        x; % Current state
        xhat; % Most recent transmission
        u;
        tx;
        
        X;
        U;
        TX;
        ERROR;
    end
    properties (Dependent)
        name; % Agent name
        error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, A, B, C, D, x0)
            % Class constructor
            obj.id = id;
            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;

            %obj.K = lqr(A, B, 1, 1);
            obj.K = 1;
            %obj.K = [1/7 -3/7; 2/7 1/7];
            
            obj.x = x0;
            obj.xhat = zeros(size(x0));
            obj.u = zeros(size(B, 2), 1);
            obj.tx = zeros(size(x0));
        end
        
        % Getters
        function name = get.name(obj)
            name = sprintf("Agent %d", obj.id);
        end
        function error = get.error(obj) 
            % Difference from last broadcast
            error = abs(obj.x - obj.xhat); 
        end
        
        
        function obj = addReceiver(obj, reciever, weight)
            % Attach a reciever to this object
            obj.followers = [obj.followers, struct('agent', reciever, 'weight', weight)];
            reciever.leaders = [reciever.leaders, struct('agent', obj, 'weight', weight)];
        end
        
        function obj = check_trigger(obj)
            % Act on error threshold
            obj.tx = obj.triggers;
            if any(obj.tx)
                obj.sample;
                obj.setinput;
                obj.broadcast;
            end
        end
        
        function obj = sample(obj)
            % Set the broadcast
            obj.xhat = obj.x .* obj.tx + obj.xhat .* ~obj.tx;
        end
        
        function obj = broadcast(obj)
            % Broadcast this object to all its neighbours
            for follower = obj.followers
                follower.agent.receive;
            end
        end
        
        function obj = receive(obj)
            obj.setinput;
        end
        
        function obj = setinput(obj)
            % Calculate the next control input
            z = zeros(size(obj.u));
            for leader = obj.leaders
                z = z + leader.weight*(obj.xhat - leader.agent.xhat);
            end
            %obj.u = -obj.K * z .* tx + obj.u .* ~tx;
            obj.u = -obj.K * z;
        end
        
        function obj = step(obj, ts)
            % Discrete Time Step
            [G, H] = c2d(obj.A, obj.B, ts);           
            obj.x = G * obj.x + H * obj.u;
        end
        
        function save(obj)     
            % Record current properties
            obj.X = [obj.X obj.x];
            obj.U = [obj.U obj.u];
            obj.ERROR = [obj.ERROR, obj.error];
            obj.TX = [obj.TX, obj.tx];
        end
    end
    
    methods (Abstract)
        triggers = triggers(obj)
    end
end