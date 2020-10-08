classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentLocalEventTrigger(id, A, B, C, D, x0, L)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
            
            % Event triggering constant
            obj.k = 1/max(eig(L));
            
            % FOR LOOP
        end
        
        function error_threshold = get.error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                sp = 0;
                %sp = [-(obj.id - leader.agent.id); 0];
                %z = z + leader.weight*(obj.x - leader.agent.x + sp);
                z = z + (obj.xhat - leader.agent.xhat + sp);
            end
            error_threshold = obj.k * abs(z);
            error_threshold = ceil(error_threshold * 2^8)/2^8;
        end
        
        
        function triggers = triggers(obj)
            % Return states crossing the error threshold
            triggers = obj.error > obj.error_threshold;%; .* [0; 1];
        end
        
        function save(obj)
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end