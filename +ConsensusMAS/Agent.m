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
        
        virtual = false;
        stepall = false;
        
        map;
        iters = 0;
        
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
        
        wind;
        wind_states;
        Dw; % Wind disturbance matrix
        S = 0.1; % Surface area
        Cd = 1; % Drag coefficient
        m = 1; % mass
        
        goal;
    end
    
    properties (Dependent)
        name; % Agent name
        %e;
        error; % Deviation from last broadcast
    end
    
    methods
        function obj = Agent(id, states, Af, Bf, controller_enum, cs, ...
                                numstates, numinputs, x0, delta, setpoint, ...
                                CLK, wind_states)
            import ConsensusMAS.ControllersEnum;
            
            % TODO: remove numstates, numinputs and get from controller
            % struct
            
            % Class constructor
            obj.id = id; % Agent id number
            obj.CLK = CLK; % Agent sampling rate
            obj.fx = states;
            obj.controller_enum = controller_enum;
            
            function reg = smc_regime(A, B)
                %{
                get_Tr = @(A, B, Tr, m, n)    
                        
                get_Az = @(A, Tr) Tr * A * (Tr');
                get_Bz = @(B, Tr) Tr * B;

                get_C = @(Az, m, n) [lqr(Az(1:n-m, 1:n-m), Az(1:n-m, n-m+1:end), 1, 1), eye(m)];

                get_regime = @(A, B, ) [...
                    get_Az(A, Tr), ...
                    get_Bz(B, Tr), ...
                    get_C(), ...
                    Tr]; 
                %}
                [n,m] = size(B);
                
                [Trp, ~] = qr(B);
                Tr = Trp';
                Tr = [Tr(m+1:n,:);Tr(1:m,:)];
                        
                Az = Tr * A * (Tr');
                Bz = Tr * B;
                
                %Q = eye(4).*[1 1 1 1];
                Q = 1;
                R = 1;
                C = [lqrd(Az(1:n-m, 1:n-m), Az(1:n-m, n-m+1:end), Q, R, CLK), eye(m)];

                reg.Az = Az;
                reg.Bz = Bz;
                reg.C = C;
                reg.Tr = Tr;
                %reg = {Az, Bz, C, Tr};      
            end
            
            switch (controller_enum)
                % TODO: c_struct Q & R
                
                case ControllersEnum.PolePlacement
                    K = lqr(Af(cs.x_op, cs.u_op), Bf(cs.x_op, cs.u_op), cs.Q, cs.R);
                    obj.controller = @(x, u, z) -K*z;
                
                case ControllersEnum.GainScheduled
                    K = @(x, u) lqrd(Af(x, u), Bf(x, u), cs.Q, cs.R, obj.CLK);
                    obj.controller = @(x, u, z) -K(x, u)*z;
                    
                case ControllersEnum.Smc                  
                    obj.stepall = true;

                    % Input based on regime
                    %get_u = @(Az, Bz, C, Tr, x) -(C*Bz)^-1*(C*Az*(Tr*x) + cs.k*sign(C * (Tr * x)));
                    get_u = @(R, x) -(R.C*R.Bz)^-1*(R.C*R.Az*(R.Tr*x) + ...
                                        cs.k*sign(R.C*(R.Tr*x)));
                    
                    % Get the regime with x, u -- > get the control input
                    % with regime, z
                    obj.controller = @(x, u, z) get_u(...
                        smc_regime(Af(x, u), Bf(x, u)), z);
                    
                otherwise
                    obj.controller = @(x, u, z) obj.t;
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
            
            global wind
            obj.wind = wind;
            
            obj.Dw = zeros(numstates, 2);
            for i = 1:length(wind_states)
                obj.Dw(wind_states(i), i) = 1/obj.m;
            end
            obj.wind_states = wind_states;
        end
        
        function name = get.name(obj)
            % Agent display name
            name = sprintf("Agent %d", obj.id);
        end
        
        %{
        function error = get.e(obj) 
            error = obj.x - obj.xhat;
        end
        %}
        function error = get.error(obj) 
            % Difference from last broadcast
            error = obj.xhat - obj.x;
            
            % Quantise
            error = floor(abs(error)*1000)/1000;
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
            
            
            %wf = obj.wind.forces(obj);
            %z = z + 0.2 * any(wf) * (obj.x - (z + wf));
            %z = z / 1.2;
            %z(6) = z(6) + obj.xhat(6)*mean([obj.transmissions_rx.weight]);
            
            
            % TODO
            base_weight = length(obj.leaders) + 1;
            self_weight = 3;

            z(6) = (obj.x(6)*self_weight + z(6)*base_weight)/(base_weight+self_weight);
            %z(6) = obj.x(6);
           
            % setpoint
            sp_nans = isnan(obj.setpoint);
            z = z .* sp_nans;
            z(~sp_nans) = obj.x(~sp_nans) - obj.setpoint(~sp_nans);
            
            % Input
            obj.goal = z;
            obj.u = obj.controller(obj.x, obj.u, z);
        end
        
        function step(obj)
            obj.t = obj.t + obj.CLK;
            
            if obj.stepall
                obj.setinput();
                %obj.u = obj.controller(obj.x, obj.u, obj.goal);
            end
            
            % Move, with input
            % This is dodgy             
            obj.x = obj.x + obj.fx(obj.x, obj.u)*obj.CLK;
            
            % exogenous disturbanece
            %obj.x = obj.x - obj.wind.forces(obj)*obj.CLK;
        

            % Add measurement noise
            %snr = 50;
            %obj.x = awgn(obj.x, snr);
        end
        
        function save(obj)     
            % Record current properties
            obj.iters = obj.iters + 1;
            obj.ERROR = [obj.ERROR, obj.error];
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