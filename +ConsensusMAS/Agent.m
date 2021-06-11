classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
        
    properties
        id;                 % Agent ID number
        iters = 0;
        t = 0;
        CLK;                % Sampling rate
        fx;                 % State functions
        controller;         % Gain matrix
        controller_enum;    % Which controller is beign used
        numstates;          % How many states
        numinputs;          % How many actuators
        leaders;            % Leading agents - necessary?
        followers;          % Following agents
        transmissions_rx;   % Transmissions received vector
        
        virtual = false;
        stepall = false;
        update_req = 1;
        
        x;          % Current state vector
        xhat;       % Most recent transmission
        u;          % Current input vector
        tx;         % Current trigger vector
        delta;      % Relative to neighbours
        setpoint;	% State setpoint
        
        X;      % State vector tracking
        U;      % Input vector tracking
        TX;     % Trigger vector tracking
        ERROR;  % Error vector tracking
        
        wind;       % Wind object
        Dw;         % Wind disturbance matrix
        sa = 0.1;    % Surface area
        Cd = 1;     % Drag coefficient
        m = 1;      % mass
        
        
        band = 0;
        sliding_gain = 1;
        SLIDE;
        
        d;
        D;
        goal;
        
        integrator = 0;
    end
    
    properties(Access=private)
        sim_struct;
        model_struct;
        controller_struct;
    end
    
    properties (Dependent)
        name;       % Agent name
        error;      % Deviation from last broadcast
        s;
        ss;         % sim_struct shortcut
        ms;         % model_struct shortcut
        cs;
        u_eq;       % Rolling mean u
    end
    
    methods
        function obj = Agent(id, ms, ...
                                controller_enum, cs, ...
                                ss, ...
                                x0, delta, setpoint, CLK)
            % Class constructor
            import ConsensusMAS.ControllersEnum;
            
            obj.id = id;                            % Agent id number
            obj.CLK = CLK;                          % Agent sampling rate
            obj.controller_enum = controller_enum;  % Agent controller
            obj.model_struct = ms;
            obj.sim_struct = ss;
            obj.controller_struct = cs;
            
            obj.numstates = ms.numstates;       % number of states
            obj.numinputs = ms.numinputs;       % number of inputs
            
            function reg = smc_regime(A, B, Q, R)
                % Transformation matrix
                [n,m] = size(B);
                [Tr, ~] = qr(B);
                Tr = Tr';
                Tr = [Tr(m+1:n,:);Tr(1:m,:)];
                
                %Tr = eye(2);
                
                % Transform
                Az = Tr * A * (Tr');
                Bz = Tr * B;
                    
                % Sub matrices
                A11 = Az(1:n-m, 1:n-m);
                A12 = Az(1:n-m, n-m+1:end);
                C = [lqrd(A11, A12, Q, R, CLK), eye(m)];
                
                obj.SLIDE = [obj.SLIDE, C*(obj.ConsensusTarget)];
 
                % Make them discrete
                [Az, Bz] = c2d(A, B, CLK);
                                
                % Return in struct
                reg.Az = Az;
                reg.Bz = Bz;
                reg.C = C*Tr;
                
                inv = (C*Tr*Bz)^-1/obj.CLK;
                obj.sliding_gain = abs(sum(inv(1,:)));
            end
            
            switch (controller_enum)                
                case ControllersEnum.PolePlacement
                    K = lqrd(...
                        ms.Af(cs.x_op, cs.u_op), ...
                        ms.Bf(cs.x_op, cs.u_op), ...
                        cs.Q, cs.R, obj.CLK);
                    obj.controller = @(x, u, z) -K*z;
                
                case ControllersEnum.GainScheduled
                    K = @(x, u) lqrd(...
                        ms.Af(x, u), ...
                        ms.Bf(x, u), ...
                        cs.Q, cs.R, obj.CLK);
                    obj.controller = @(x, u, z) -K(x, u)*z;
                    
                case ControllersEnum.Smc                  
                    obj.stepall = true;
                    obj.band = obj.CLK*cs.k/(1-obj.CLK*cs.tau);
                    
                    % Calculate input based off regime, x
                    get_u = @(R, x) -(R.C*R.Bz)^-1*(...
                                R.C*R.Az*x - ...
                                (1-obj.CLK*cs.tau)*R.C*x + ...
                                obj.CLK*cs.k*sign(R.C*x));
                    
                    % Controller closure
                    obj.controller = @(x, u, z) get_u(...
                        smc_regime(ms.Af(x, u), ms.Bf(x, u), cs.Qsmc, cs.Rsmc), ...
                        z);
                    
                otherwise
                    obj.controller = @(x, u, z) obj.t;
            end
            
            obj.x = x0;                         % Agent current state
            obj.xhat = x0;                      % Agent last broadcase
            obj.u = zeros(obj.numinputs, 1);    % Agent control input
            obj.d = zeros(obj.numstates, 1);    % Agent control input
            obj.delta = delta;                  % Agent relative displacement
            obj.setpoint = setpoint;            % Non-network setpoints
            
            obj.tx = zeros(size(x0));           % Agent current transmission
            obj.transmissions_rx = [];          % received vectors
            
            % Agent trajectory, with euler approx (x = x + (dx/dt)*ts)
            if ~ms.linear
                obj.fx = ms.states; 
            else
                [G, H] = c2d(ms.Af(0, 0), ms.Bf(0, 0), CLK);
                obj.fx = @(x, u) ((G*x + H*u) - x)/CLK;
            end
            
            % Wind
            global wind
            obj.wind = wind;
            obj.Dw = zeros(obj.numstates, 2);
            for i = 1:length(ss.wind_states)
                obj.Dw(ss.wind_states(i), i) = 1/obj.m;
            end
        end
        
        function name = get.name(obj)
            % Agent display name
            name = sprintf("Agent %d", obj.id);
        end
        
        function s = get.s(obj)
            if ~isempty(obj.SLIDE)
                s = obj.SLIDE(:,end);
            else
                s = Inf * ones(size(obj.x));
            end
        end
        
        function ss = get.ss(obj)
            ss = obj.sim_struct;
        end
        function ms = get.ms(obj)
            ms = obj.model_struct;
        end
        function cs = get.cs(obj)
            cs = obj.controller_struct;
        end
        
        
        function sld = sliding(obj, varargin)
            tolerance = 1;
            if nargin == 2
                tolerance = varargin{1};
            end
            sld = all(abs(obj.s) < obj.band*tolerance);
        end
        
        function u = get.u_eq(obj)
            backtrack = 10 * 1/(100*obj.CLK) + 1;
            u = obj.U(:,max(length(obj.U)-backtrack, 1):end);
            
            for i = 1:obj.numinputs
                low = mean(u(u < 0));
                high = mean(u(u > 0));
                
                if ~isnan(low) && ~isnan(high)
                    u(i) = (low + high)/2;
                elseif isnan(high)
                    u(i) = low;
                else% isnan(low)
                    u(i) = high;
                end
            end
        end
        
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
                
                obj.update_req = 1;
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
                        
                        obj.update_req = 1;
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
            % Set the broadcas
            if (obj.controller_enum == ConsensusMAS.ControllersEnum.Smc) ...
                    && (obj.sliding(1.05))
                samples = size(obj.X, 2);
                if samples > 1
                    avgd = any(obj.ms.Bf(obj.x, obj.u), 2);
                    x_avg = mean(obj.X(:,samples-1:samples), 2);
                    obj.xhat = x_avg .* obj.tx .* avgd + obj.x .* ~avgd + obj.xhat .* ~obj.tx;
                else
                    obj.xhat = obj.x .* obj.tx + obj.xhat .* ~obj.tx;
                end
            else
                obj.xhat = obj.x .* obj.tx + obj.xhat .* ~obj.tx;
            end
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
                %{
                z = z + transmission.weight*(...
                    (obj.xhat - transmission.xhat) + ... % Difference of states
                    (obj.delta - transmission.agent.delta) ... % Relative Offset
                );
                %}
            
                z = z + transmission.weight*(...
                    (obj.x - transmission.xhat) + ... % Difference of states
                    (obj.delta - transmission.agent.delta) ... % Relative Offset
                );
            end
            
            % setpoint
            sp_nans = isnan(obj.setpoint);
            z = z .* sp_nans;
            z(~sp_nans) = obj.x(~sp_nans) - obj.setpoint(~sp_nans);
            
            
            %
            
            %z(2) = (z(2)*remultiplier + (obj.x(2) - 1))/(remultiplier + 1);
            %z(4) = (z(4)*remultiplier + (obj.x(4) - 1))/(remultiplier + 1);
            %z(6) = (z(6)*remultiplier + 2*remultiplier*(obj.x(6) - 0))/(remultiplier*3);
            
            %{
            z(1) = z(1)*rescaler;
            z(2) = z(2)*rescaler + (obj.x(2) - -14.28)/(remultiplier + 1);
            z(3) = z(3)*rescaler;
            z(5) = z(5)*rescaler;
            z(6) = z(6)*rescaler;
            %}
            
            %remultiplier = length(obj.leaders) + 1; 
            %rescaler = (remultiplier / (remultiplier + 1));
            %z(2) = z(2)*rescaler + (obj.x(2) - -3.26)/(remultiplier + 1);
            %z(4) = z(4)*rescaler + (obj.x(4) - -3.88)/(remultiplier + 1);
            
            %{
            obj.integrator = obj.integrator + obj.x(6)*obj.CLK;
            
            
           
            rescaler = (remultiplier / (remultiplier + 1));
          
            z(4) = z(4)*rescaler + (obj.x(4) - -3.58)/(remultiplier + 1);
            z(6) = obj.x(6) + obj.integrator/3;% - z(6)*rescaler;
            %z(6) = obj.x(6);    
            %}
        end
        
        function set_controller(obj)
            import ConsensusMAS.ControllersEnum;
            
            if (obj.update_req || obj.stepall)
                % Set the input on broadcast, or receive
                obj.check_receive()

                % Consensus goal
                z = obj.ConsensusTarget();
                
                % SMC control input jitter, need a better representation
                if (obj.controller_enum == ControllersEnum.Smc) && (obj.sliding)
                    u_in = obj.u_eq;
                else
                    u_in = obj.u;
                end
                
                % Input
                obj.goal = z;
                obj.u = obj.controller(obj.x, u_in, z);
            end
            
            obj.update_req = 0;
        end

        
        function step(obj)
            obj.t = obj.t + obj.CLK;

            % Move, with input          
            obj.x = obj.x + obj.fx(obj.x, obj.u)*obj.CLK;
            
            % exogenous disturbanece
            obj.d = obj.wind.forces(obj);
            
            
            if ~(obj.id == 1)
                obj.x = obj.x - obj.d*obj.CLK;
            end
            
           
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
            obj.D = [obj.D, obj.d];
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