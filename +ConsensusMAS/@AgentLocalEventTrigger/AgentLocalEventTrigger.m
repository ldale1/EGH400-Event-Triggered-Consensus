classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    
    properties
        c;
        alpha;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        F;
    end
    
    methods
        function obj = AgentLocalEventTrigger(id, A, B, C, D, K, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, setpoint, CLK);
            
            % Event triggering constant
            obj.c = 0.5;
            obj.alpha = 0.999;
        end
        
        function set.F(obj, F)
            % Change the exponential power
            I = eye(size(F, 1));
            J = jordan(I - F);

            % Calculate Xi matrix
            I1 = eye(size(F,1)-1);
            delta = J(2:end, 2:end);
            Xi = kron(I1, obj.G) + kron(delta, -obj.H*obj.K);
            eigs_Xi_max = max(eigs(Xi));
            
            if (eigs_Xi_max  > 1)
            	fprintf("Max Xi eigenvalue %.2f too large", eigs_Xi_max);
            end
            
            obj.alpha = 0.92;
        end
        
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            % Project forwards, without input
            obj.xhat = obj.G * obj.xhat;
            
            % Estimate other agentss
            for i = 1:length(obj.transmissions_rx)
                obj.transmissions_rx(i).xhat = ...
                    obj.transmissions_rx(i).agent.G * ...
                    obj.transmissions_rx(i).xhat;
            end
        end
        
        function error = error(obj) 
            % Difference from last broadcast
            error = norm(obj.xhat - obj.x) * ones(size(obj.x));
            error = floor(abs(error)*1000)/1000;
        end

        function error_threshold = error_threshold(obj)            
            % Consensus
            t = obj.iter * obj.CLK;
            error_val = obj.c * obj.alpha^t;
            error_threshold = ones(size(obj.x)) * error_val;
        end
        
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error >= obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end