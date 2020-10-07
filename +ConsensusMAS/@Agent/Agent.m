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
        leaders;
        followers; % Neighbouring agents
        
        
        x; % Current state
        xhat; % Most recent transmission
        X;
        u;
        U;
        tx;
        TX;
        ERROR;
        %tx;
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
            %obj.K = lqr(A, B, 1, 3);
            obj.K = [1/7 -3/7; 2/7 1/7];
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
            error = abs(obj.x - obj.xhat); 
        end
        
        %{
        function set.u(obj, x)          
            obj.U = [obj.X x];
        end
        function u = get.u(obj)
            u = obj.U(:,end); 
        end
        %}
        
        function obj = addReceiver(obj, reciever, weight)
            % Attach a reciever to this object
            obj.followers = [obj.followers, struct('agent', reciever, 'weight', weight)];
            reciever.leaders = [reciever.leaders, struct('agent', obj, 'weight', weight)];
        end
        
        function triggers = checkbroadcast(obj)
            triggers = obj.trigger;
            
            obj.tx = triggers;
            obj.xhat = obj.x .* triggers + obj.xhat .* ~triggers;
            %if any(obj.tx)
            %    obj.broadcast(obj.tx);
            %end
        end
        
        function obj = broadcast(obj, triggers)
            % Broadcast this object to all its neighbours
            
            %obj.setinput(triggers);
            %for follower = obj.followers
            %    follower.agent.receive(triggers);
            %end
        end
        
        function obj = receive(obj, triggers)
            obj.setinput(triggers);
        end
        
        function obj = setinput(obj)
            % Calculate the next control input
            z = zeros(size(obj.u));
            for leader = obj.leaders
                z = z + leader.weight*(obj.xhat - leader.agent.xhat);
            end
            obj.u = -obj.K * z;
            %obj.u = F .* + obj.u .* ~triggers;
        end
        
        function obj = step(obj, ts)
            %{
            % Step the agent
            xdot = obj.A * obj.x + obj.B * obj.u;

            % Simulate
            [t, y] = ode45(@(t,y) xdot, [0 ts], obj.x);
            obj.x = y(end,:)';
            %}
            [G, H] = c2d(obj.A, obj.B, ts);
            obj.x = G * obj.x + H * obj.u;
        end
        
        function track(obj)      
            obj.X = [obj.X obj.x];
            obj.U = [obj.U obj.u];
            obj.ERROR = [obj.ERROR, obj.error];
            obj.TX = [obj.TX, obj.tx];
        end
    end
    
    methods (Abstract)
        result = trigger(obj)
    end
end