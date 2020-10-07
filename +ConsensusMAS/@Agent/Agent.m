classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        id; % Agent ID number
        A;
        B;
        C;
        D;
        K;
        leaders;
        followers; % Neighbouring agents
        xhat; % Most recent transmission
        X; % State array
        U; % Control input array
        tx;
    end
    properties (Dependent)
        name; % Agent name
        x; % Current state
        u; % Current control input
        error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, A, B, C, D, x0)
            % Class constructor
            obj.id = id;
            obj.x = x0;
            obj.xhat = zeros(size(x0));
            obj.u = zeros(size(x0));
            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            obj.K = [1/7 -3/7; 2/7 1/7]%; lqr(A,B,1,1, eye(size(B)));
            obj.tx = false;
        end
        
        % Getters
        function name = get.name(obj)
            name = sprintf("Agent %d", obj.id);
        end
        function set.x(obj, x)
            obj.X = [obj.X, x]; 
        end
        function x = get.x(obj)
            x = obj.X(:,end); 
        end
        function set.u(obj, u)
            obj.U = [obj.U, u]; 
        end
        function u = get.u(obj)
            u = obj.U(:,end); 
        end
        function error = get.error(obj) 
            error = abs(obj.x - obj.xhat); 
        end
       
        
        function obj = addReceiver(obj, reciever, weight)
            % Attach a reciever to this object
            obj.followers = [obj.followers, struct('agent', reciever, 'weight', weight)];
            reciever.leaders = [reciever.leaders, struct('agent', obj, 'weight', weight)];
        end
        
        function triggers = checktrigger(obj)
            triggers = obj.trigger;
            if any(reshape(squeeze(triggers), [], 1))
                obj.broadcast(triggers);
            end
        end
        
        function obj = broadcast(obj, triggers)
            % Broadcast this object to all its neighbours
            obj.tx = true;
            obj.setinput;
            obj.xhat = obj.x .* triggers + obj.xhat .* ~triggers;
            for follower = obj.followers
                follower.agent.receive;
            end
        end
        
        function obj = receive(obj)
            obj.setinput();
            %if ~obj.tx
            %    obj.setinput();
            %end
        end
        
        function obj = setinput(obj)
            % Calculate the next control input
            input = zeros(size(obj.x));
            for leader = obj.leaders
                sp = 0;
                %sp = [-(obj.id - leader.agent.id); 0];
                input = input - leader.weight*((obj.xhat - leader.agent.xhat) + sp);
            end
            obj.u = obj.K * input;% .* triggers + obj.u .* ~triggers;
        end
        
        function obj = step(obj, ts)
            % Step the agent
            xdot = obj.A * obj.x + obj.B * obj.u;

            % Simulate
            [t, y] = ode45(@(t,y) xdot, [0 ts], obj.x);
            obj.x = y(end,:)'; 
        end
    end
    
    methods (Abstract)
        result = trigger(obj)
    end
end