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
        iter; % Discrete steps count
        
        leaders; % Leading agents
        followers; % Following agents
        
        x; % Current state vector
        xhat; % Most recent transmission
        delta;
        setpoint;
        u; % Current input vector
        tx; % Current trigger vector
        
        X; % States matrix
        U; % Inputs matix
        TX; % Trigger matrix
        ERROR; % Error matrix
    end
    properties (Dependent)
        name; % Agent name
        %error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, A, B, C, D, K, x0, delta, setpoint,  CLK)
            % Class constructor
            obj.id = id; % Agent id number
            obj.CLK = CLK; % Agent sampling rate
            
            [obj.G, obj.H] = c2d(A, B, CLK); % Discrete time ss
            obj.C = C; % ss
            obj.D = D; % ss
            obj.K = K; % Agent gain 
            
            obj.iter = 1;
            obj.x = x0; % Agent current state
            obj.delta = delta; % Agent relative displacement
            obj.setpoint = setpoint;
            
            obj.xhat = x0; % Agent last broadcase
            obj.u = zeros(size(B, 2), 1); % Agent control input
            obj.tx = zeros(size(x0)); % Agent current transmission
        end
        
        function name = get.name(obj)
            % Agent display name
            name = sprintf("Agent %d", obj.id);
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
            z = zeros(size(obj.H, 1),1);
            for leader = obj.leaders     
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.xhat - xj.xhat) + ...
                    (obj.delta - xj.delta));
            end
            
            % setpoint
            setpoint_nans = isnan(obj.setpoint);
            z = z .* setpoint_nans;
            z(~setpoint_nans) = obj.x(~setpoint_nans) - obj.setpoint(~setpoint_nans);
            
            % Input
            obj.u = -obj.K * z;
        end
        
        function step(obj)               
            % Move, with input
            obj.x = obj.G * obj.x + obj.H * obj.u;
            
            % Discrete step count
            obj.iter = obj.iter + 1;
        end
        
        function save(obj)     
            % Record current properties
            obj.X = [obj.X obj.x];
            obj.U = [obj.U obj.u];
            obj.TX = [obj.TX, obj.tx];
        end
    end
    
    methods (Abstract)
        triggers = triggers(obj)
    end
end