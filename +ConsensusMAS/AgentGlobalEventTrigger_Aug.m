classdef AgentGlobalEventTrigger_Aug < ConsensusMAS.Agent
    % This class represents an event-triggered agent
    
    properties
        k;
        ERROR_THRESHOLD;
        trigger_states;
        
        et_min = 0.05;
    end
    
    properties (Dependent)
        L;
    end
    
    methods
        function obj = AgentGlobalEventTrigger_Aug(id, model_struct, controller, c_struct, sim_struct, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, model_struct, controller, c_struct, sim_struct, x0, delta, setpoint, CLK);
            
            % Override
            obj.xhat = zeros(size(x0));
            
            % Event triggering constant
            obj.k = 0;
            
            obj.trigger_states = model_struct.trigger_states;
            
            % Checks
            if (obj.controller_enum ~= ConsensusMAS.ControllersEnum.Smc)
                warn("Should only be used with SMC");
            end
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        function error = error(obj) 
            % Difference from last broadcast
            error = obj.xhat - obj.x;
            
            % Quantise
            error = floor(abs(error)*1000)/1000;
        end
        
        %{
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            % Project forwards, without input
            obj.xhat = obj.xhat + obj.fx(obj.xhat, zeros(obj.numinputs, 1))*obj.CLK;
            
            % Estimate other agents
            for i = 1:length(obj.transmissions_rx)
                leader = obj.transmissions_rx(i).agent;
                transmission = obj.transmissions_rx(i).xhat;
                obj.transmissions_rx(i).xhat = ...
                    transmission + ...
                    leader.fx(transmission, zeros(leader.numinputs, 1))*leader.CLK;
            end
        end
        %}
        
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            
            if any(isnan(obj.xhat))
                a = 1;
            end
            
            % Project forwards, without input
            obj.xhat = obj.xhat + obj.fx(obj.xhat, zeros(obj.numinputs, 1))*obj.CLK;
            
            if any(isnan(obj.xhat))
                a = 1;
            end
            
            % Estimate other agents
            for i = 1:length(obj.transmissions_rx)
                leader = obj.transmissions_rx(i).agent;
                transmission = obj.transmissions_rx(i).xhat;
                obj.transmissions_rx(i).xhat = ...
                    transmission + ...
                    leader.fx(transmission, zeros(leader.numinputs, 1))*leader.CLK;
            end
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta));
            end
                        
            % Consensus
            error_threshold = obj.k * norm(abs(z(obj.trigger_states)));
            error_threshold = error_threshold * ones(size(obj.x));
            
            if (obj.sliding)
                A = obj.ms.Af(obj.x_eq, obj.u_eq);
                B = obj.ms.Bf(obj.x_eq, obj.u_eq);
            else
                A = obj.ms.Af(obj.x, obj.u);
                B = obj.ms.Bf(obj.x, obj.u);
            end
            
            [~, H] = c2d(A, B, obj.CLK);
            %mins = (abs(sum(H,2)) + sum(abs(H),2) * 0.25 ) * obj.cs.k * obj.sliding_gain;
            %mins = (sum(abs(H),2) * 2.1 ) * obj.cs.k * obj.sliding_gain;
            
            try
            mins = 2*abs(H)*abs(obj.sliding_gain)*obj.cs.k*obj.CLK*ones(obj.numinputs, 1);
            catch
                a = 1
            end
            global eta;
            error_threshold = max(error_threshold, (1 + eta)*mins + obj.et_min);
        end
     
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            %triggers = (norm(obj.error(obj.trigger_states)) * ones(size(obj.x)) > obj.error_threshold);
            triggers = (norm(obj.error(obj.trigger_states)) * ones(size(obj.x)) > obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end  
        end
        
        %{
        function setinput(obj)
            z = obj.ConsensusTarget();
            for i = 1:length(z)
                z(i) = abs(z(i))^2*sign(z(i));
            end
            obj.u = -[1 1] * z;
        end
        %}
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end