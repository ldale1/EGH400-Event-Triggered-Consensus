classdef AgentGlobalEventTrigger < ConsensusMAS.Agent
    % This class represents an event-triggered agent
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        L;
    end
    
    methods
        function obj = AgentGlobalEventTrigger(id, A, B, C, D, x0, delta, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0, delta, CLK);
            
            % Event triggering constant
            obj.k = 0;
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.xhat - xj.xhat) + ...
                    (obj.delta - xj.delta) ...
                    );
            end
            
            % Consensus
            error_threshold = obj.k * abs(z);
        end
     
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error > obj.error_threshold);
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