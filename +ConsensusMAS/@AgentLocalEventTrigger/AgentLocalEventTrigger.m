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

        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            c = 0.5;
            alpha = 0.92;
            
            
            
            y = zeros(size(obj.x)); 
            e = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                y = y + leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta) ...
                    );
                
                e = e + leader.weight*(...
                    (obj.error - xj.error)...
                    );
            end
            
            
            % Consensus
            error_threshold = [c * alpha ^ floor(obj.iter / 5); c * alpha ^ floor(obj.iter / 5)];
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