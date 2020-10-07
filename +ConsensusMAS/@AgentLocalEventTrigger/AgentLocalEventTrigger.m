classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        c0;
        c1;
        alpha;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentLocalEventTrigger(id, A, B, C, D, x0, L, c0, c1)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
            
            % Event triggering constant
            obj.c0 = c0;
            obj.c1 = c1;
            obj.alpha = 1/max(eig(L));
        end
        
        function error_threshold = get.error_threshold(obj)
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                z = z + leader.weight*(obj.x - leader.agent.x);
            end
            error_threshold = obj.alpha * abs(z);
        end
        
        
        function triggers = triggers(obj)
            triggers = obj.error > obj.error_threshold;
        end
        
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end