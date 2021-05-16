classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    % TODO: What about tx and rx in same step ?
    
    properties
        id; % Agent ID number
        t = 0;
        CLK; % Sampling rate
        fx;
        controller; % Gain matrix
        controller_enum;
        numstates;
        numinputs;
        leaders; % Leading agents - necessary?
        followers; % Following agents
        transmissions_rx; % Transmissions received vector
        
        map;
        
        x; % Current state vector
        xhat; % Most recent transmission
        u; % Current input vector
        tx; % Current trigger vector
        delta; % Relative to neighbours
        setpoint; % State setpoint
        
        X; % State vector tracking
        U; % Input vector tracking
        TX; % Trigger vector tracking
        ERROR; % Error vector tracking
        
        wind_states;
        Dw; % Wind disturbance matrix
        S = 0.1; % Surface area
        Cd = 1; % Drag coefficient
        m = 1; % mass
    end
    
    properties (Dependent)
        name; % Agent name
        e;
        %error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, states, Af, Bf, controller_enum, cs, numstates, numinputs, x0, delta, setpoint, CLK, wind_states)
            import ConsensusMAS.ControllersEnum;
            
            % TODO: remove numstates, numinputs and get from controller
            % struct
            
            % Class constructor
            obj.id = id; % Agent id number
            obj.CLK = CLK; % Agent sampling rate
            obj.fx = states;
            obj.controller_enum = controller_enum;
            
            switch (controller_enum)
                % TODO: c_struct Q & R
                
                case ControllersEnum.PolePlacement
                    K = lqr(Af(x, u), Bf(cs.x_op, cs.u_op), 1, 1);
                    obj.controller = @(x, u, z) -K*z;
                
                case ControllersEnum.GainScheduled
                    K = @(x, u) lqr(Af(x, u), Bf(x, u), 1, 1);
                    obj.controller = @(x, u, z) -K(x, u)*z;
                    
                case ControllersEnum.SmcScheduled
                    map = containers.Map;
                    for target = cs.round_targets
                        n = cs.n;
                        m = cs.m;
                        x = cs.target_x(target);
                        u = cs.target_u(target);
                        
                        % Linear point
                        A = Af(x, u);
                        B = Bf(x, u);

                        % Transformation
                        [Trp, ~] = qr(B);
                        Tr = Trp';
                        Tr = [Tr(m+1:n,:);Tr(1:m,:)];

                        % Transformed!
                        Az = Tr * A * (Tr');
                        Bz = Tr * B;

                        % Gains
                        A11 = Az(1:n-m, 1:n-m);
                        A12 = Az(1:n-m, n-m+1:end);
                        C1 = lqr(A11, A12, 1, 1);
                        C = [C1, eye(n-m)];

                        regime.t = target;
                        regime.Az = Az;
                        regime.Bz = Bz;
                        regime.C = C;
                        regime.Tr = Tr;

                        map(string(target)) = regime;
                    end
                    
                    % Regime based off operating conditions
                    get_key = @(x) interp1(...
                        cs.round_targets, cs.round_targets, ...
                        cs.map_state(x), 'nearest');
                    get_regime = @(x) map(string(get_key(x)));
                    
                    % Input based on regime
                    get_s = @(r, x) r.C * (r.Tr * x);
                    get_u = @(r, x) -(r.C*r.Bz)^-1*(r.C*r.Az*(r.Tr*x) + cs.k*sign(get_s(r, x)));
                    
                    % Get the regime with x, u -- > get the control input
                    % with regime, z
                    obj.controller = @(x, u, z) get_u(get_regime(x), z);

                otherwise
                    error("Unrecognised type");
            end
            
            obj.numstates = numstates;
            obj.numinputs = numinputs;
                        
            obj.x = x0; % Agent current state
            obj.delta = delta; % Agent relative displacement
            obj.setpoint = setpoint;
            
            obj.xhat = x0; % Agent last broadcase
            obj.u = zeros(obj.numinputs, 1); % Agent control input
            obj.tx = zeros(size(x0)); % Agent current transmission
            
            obj.transmissions_rx = []; % received vectors
            
            obj.wind_states = wind_states;
            obj.Dw = zeros(numstates, 2);
            for i = 1:length(wind_states)
                obj.Dw(wind_states(i), i) = 1/obj.m;
            end
        end
        
        function name = get.name(obj)
            % Agent display name
            name = sprintf("Agent %d", obj.id);
        end
        
        function error = get.e(obj) 
            error = obj.x - obj.xhat;
        end
    end
    
    
    methods
       
        function addReceiver(obj, reciever, weight)
            % Attach a reciever to this object
            obj.followers = [obj.followers, struct('agent', reciever, 'weight', weight)];
            reciever.leaders = [reciever.leaders, struct('agent', obj, 'weight', weight)];
            
            % What is coming in
            % Add this object to the list
            reciever.transmissions_rx = [...
                reciever.transmissions_rx,  ...
                struct(...
                    'agent', obj, ...
                    'weight', weight, ...
                    'xhat', nan(size(obj.xhat)), ...%obj.xhat, ...
                    'buffer', struct([]) ...
                )];
        end
        
        function check_trigger(obj)
            % Act on error threshold
            obj.tx = obj.triggers();
            if any(obj.tx)
                obj.sample();
                obj.broadcast();
                obj.setinput();
            end
        end
        
        function check_receive(obj)
            % Look for new transmissions
            for i = 1:length(obj.transmissions_rx)
                rx = obj.transmissions_rx(i);
                
                if ~isempty(rx.buffer)
                    % Best transmission
                    last = find([rx.buffer.delay] < 1, 1, 'last');
                    if ~isempty(last) 
                        obj.transmissions_rx(i).xhat = rx.buffer(last).xhat;
                        obj.transmissions_rx(i).buffer = rx.buffer(last+1:end);
                        obj.setinput()
                    end
                end
            end
        end
        
        
        function shift_receive(obj)
            % Move the transmissions buffer along
            for i = 1:length(obj.transmissions_rx)
                rx = obj.transmissions_rx(i);
                
                if ~isempty(rx.buffer)
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
            % Broadcasts with delay to all followers
            for follower = obj.followers
                                
                % Filter for leading obj
                leading_agents = [follower.agent.transmissions_rx.agent];
                leading_obj = ([leading_agents.id] == obj.id);                
   
                % Add to receiver buffer
                follower.agent.transmissions_rx(leading_obj).buffer = [
                    follower.agent.transmissions_rx(leading_obj).buffer, ...
                    struct(...
                        'xhat', obj.xhat, ...
                        'delay', 0 ... %
                    )];
            end
        end
        
        function z = ConsensusTarget(obj)
            z = zeros(obj.numstates, 1);
            for transmission = obj.transmissions_rx                
                % Consensus summation
                z = z + transmission.weight*(...
                    (obj.xhat - transmission.xhat) + ... % Difference of states
                    (obj.delta - transmission.agent.delta) ... % Relative Offset
                );
            end
        end
        
        function setinput(obj)
            % Set the input on broadcast, or receive
            obj.check_receive()
            
            % Consensus goal
            z = obj.ConsensusTarget();
           
            % setpoint
            sp_nans = isnan(obj.setpoint);
            z = z .* sp_nans;
            z(~sp_nans) = obj.x(~sp_nans) - obj.setpoint(~sp_nans);
            
            % Input
            obj.u = obj.controller(obj.x, obj.u, z);
        end
        
        function step(obj)
            obj.t = obj.t + obj.CLK;
            
            % Move, with input
            % This is dodgy             
            obj.x = obj.x + obj.fx(obj.x, obj.u)*obj.CLK;

            % Add measurement noise
            %snr = 50;
            %obj.x = awgn(obj.x, snr);
        end
        
        function save(obj)     
            % Record current properties
            obj.X = [obj.X obj.x];
            obj.U = [obj.U obj.u];
            obj.TX = [obj.TX, obj.tx];
        end
    end
    
    methods (Static)
        function y = sig(x, a)
            y = ones(size(x));
            for i = 1:length(x)
                y(i) = abs(x(i))^a * sign(x(i));
            end
        end
    end
    
    methods (Abstract)
        triggers = triggers(obj)
    end
end