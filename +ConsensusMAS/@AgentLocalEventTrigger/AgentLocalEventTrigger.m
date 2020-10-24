classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        L;
    end
    
    methods
        function obj = AgentLocalEventTrigger(id, A, B, C, D, K, x0, delta, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, CLK);
            
            % Event triggering constant
            obj.k = 0;
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            % Project forwards, without input
            obj.xhat = obj.G * obj.xhat;
        end

        function error_threshold = error_threshold(obj)            
            % Consensus
            c = 0.5;
            alpha = 0.92;
            
            error_val = c * alpha ^ (obj.iter * obj.CLK);
            error_threshold = ones(size(obj.x)) * error_val;
        end
        
        function error = error(obj) 
            % Difference from last broadcast
            error = norm(obj.xhat - obj.x) * ones(size(obj.x));
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
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end