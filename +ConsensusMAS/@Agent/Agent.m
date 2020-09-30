classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        id; % Agent ID number
        leaders;
        followers; % Neighbouring agents
        xhat; % Most recent transmission
        X; % State array
        U; % Control input array
    end
    properties (Dependent)
        name; % Agent name
        x; % Current state
        u; % Current control input
        error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, x0)
            % Class constructor
            obj.id = id;
            obj.x = x0;
            obj.xhat = x0;
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
            obj.broadcast(triggers);
        end
        
        function obj = broadcast(obj, triggers)
            % Broadcast this object to all its neighbours
            obj.xhat = obj.x .* triggers + obj.xhat .* ~triggers;
            if any(reshape(squeeze(triggers), [], 1))
                for follower = obj.followers
                    follower.agent.receive;
                end
            end
        end
        
        function obj = receive(obj)
            obj.setinput();
        end
        
        function obj = setinput(obj)
            % Calculate the next control input
            input = 0;
            for leader = obj.leaders
                input = input - leader.weight*(obj.xhat - leader.agent.xhat);
            end
            obj.u = input;% .* triggers + obj.u .* ~triggers;
        end
        
        function obj = step(obj, ts)
            % Step the agent, first order dynamics
            obj.x = obj.x + obj.u * ts;
        end
    end
    
    methods (Abstract)
        result = trigger(obj)
    end
end