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
        
        transmissions_rx;
        
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
            
            % What is coming in
            reciever.transmissions_rx = [...
                reciever.transmissions_rx,  ...
                struct(...
                    'agent', obj, ...
                    'weight', weight, ...
                    'xhat', obj.xhat, ...
                    'buffer', struct([]) ...
                )];
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
        
        function check_receive(obj)
            for i = 1:length(obj.transmissions_rx)
                rx = obj.transmissions_rx(i);
                
                if length(rx.buffer) > 1
                    % Best transmission
                    last = find([rx.buffer.delay] <= 1, 1, 'last');
                    if ~isempty(last) 
                        obj.transmissions_rx(i).xhat = rx.buffer(last).xhat;
                        obj.transmissions_rx(i).buffer = rx.buffer(last+1:end);

                        % We got something
                        obj.setinput()
                    end

                    % Move everything up in buffer
                    for j = 1:length(obj.transmissions_rx(i).buffer)
                        obj.transmissions_rx(i).buffer(j).delay = ...
                            obj.transmissions_rx(i).buffer(j).delay - 1; 
                    end
                end
                                
                
            end
        end
        
        function sample(obj)
            % Set the broadcast
            obj.xhat = obj.x .* obj.tx + obj.xhat .* ~obj.tx;
        end
        
        function broadcast(obj)
            
            for follower = obj.followers
                %follower.agent.receive();
            end
            
            % Broadcasts with delay
            for follower = obj.followers
                                
                % Filter for leading obj
                leading_agents = [follower.agent.transmissions_rx.agent];
                leading_obj = ([leading_agents.id] == obj.id);
                
                if sum(leading_obj) > 1
                    ;
                end
                
                % Add to receiver buffer
                follower.agent.transmissions_rx(leading_obj).buffer = [
                    follower.agent.transmissions_rx(leading_obj).buffer, ...
                    struct(...
                        'xhat', obj.xhat, ...
                        'delay', 1 ... % randi(3)
                    )];
            end
        end
        
        function receive(obj)
            % Leader broadcast notification
            fprintf("WARN\n")
            fprintf("receive, shouldn't be called\n")
            obj.setinput();
        end
        
        function setinput(obj)
            % Calculate the next control input
            z = zeros(size(obj.H, 1),1);
            for transmission = obj.transmissions_rx                
                % Consensus summation
                z = z + transmission.weight*(...
                    (obj.xhat - transmission.xhat) + ...
                    (obj.delta - transmission.agent.delta));
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
            
            % Add measurement noise
            %snr = 1;
            %obj.x = awgn(obj.x, snr, 'measured');
            
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