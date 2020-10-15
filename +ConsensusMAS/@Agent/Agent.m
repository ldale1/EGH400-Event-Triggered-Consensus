classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    % What about tx and rx in same step ?
    
    properties
        id; % Agent ID number
        CLK; % Sampling rate
        G; % Discrete time state matrix
        H; % Discrete time input matrix
        C; % Output matrix
        D; % 
        K; % Gain matrix
        
        leaders; % Leading agents
        followers; % Following agents
        
        x; % Current state vector
        xhat; % Most recent transmission
        u; % Current input vector
        tx; % Current trigger vector
        
        X; % States matrix
        U; % Inputs matix
        TX; % Trigger matrix
        ERROR; % Error matrix
        
        txt; % time since recent transmission
    end
    properties (Dependent)
        name; % Agent name
        error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, A, B, C, D, CLK, x0)
            % Class constructor
            obj.id = id;
            obj.CLK = CLK;
            
            [obj.G, obj.H] = c2d(A, B, CLK);
            obj.C = C;
            obj.D = D;

            %obj.K = lqr(A, B, 1, 1);
            %obj.K = ones(size(B'));
            obj.K = [1/7 -3/7; 2/7 1/7];
            
            obj.x = x0;
            obj.xhat = zeros(size(x0));
            obj.u = zeros(size(B, 2), 1);
            obj.tx = ones(size(x0));
        end
        
        
        function name = get.name(obj)
            % Agent display name
            name = sprintf("Agent %d", obj.id);
        end
        function error = get.error(obj) 
            % Difference from last broadcast
            error = obj.xhat - obj.x;
            %error = (obj.G^obj.txt)*obj.xhat - obj.x;
            error = floor(abs(error)*1000)/1000;
        end
    end
    
    
    methods
        function addReceiver(obj, reciever, weight)
            % Attach a reciever to this object
            obj.followers = [obj.followers, struct('agent', reciever, 'weight', weight)];
            reciever.leaders = [reciever.leaders, struct('agent', obj, 'weight', weight)];
        end
        
        function check_trigger(obj)
            % Act on error threshold
            obj.tx = obj.triggers();
            if any(obj.tx)
                obj.sample();
                obj.setinput();
                obj.broadcast();
            end
        end
        
        function sample(obj)
            % Set the broadcast
            obj.xhat = obj.x .* obj.tx + obj.xhat .* ~obj.tx;
        end
        
        function broadcast(obj)
            % Broadcast this object to all its neighbours
            for follower = obj.followers
                follower.agent.receive();
            end
        end
        
        function receive(obj)
            % Leader broadcast notification
            obj.setinput();
        end
        
        function setinput(obj)
            % Calculate the next control input
            z = zeros(size(obj.u));
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                        obj.xhat - xj.xhat);
            end
            obj.u = -obj.K * z;
        end
        
        function step(obj)
            % Discrete Time Step
            obj.txt = obj.txt + 1;
               
            % Move
            obj.x = obj.G * obj.x + obj.H * obj.u;
            
            % Project forwards (may require [1;1] tx)
            obj.xhat = (obj.G) * obj.xhat;
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