classdef AgentGlobalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        k;
    end
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentGlobalEventTrigger(id, A, B, C, D, x0, ADJ)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
            
            % Event triggering constant
            D = diag(sum(ADJ, 2));
            L = D - ADJ;
            I = eye(size(ADJ, 1));
            Ln = (I + D)^-1*L;
            F = (I + D)^-1 * (I * ADJ);
            obj.k = max(eig(L));
        end
        
        function error_threshold = get.error_threshold(obj)
            z = 0; 
            for leader = obj.leaders
                sp = 0;
                %sp = [-(obj.id - leader.agent.id); 0];
                
                
                %z = z - leader.weight*(obj.xhat - leader.agent.xhat + sp);
                z = z + leader.weight*(obj.x - leader.agent.x + sp);
            end
            error_threshold = 1/obj.k * abs(z);
        end
        
        
        function result = trigger(obj)
            result = obj.error > obj.error_threshold;
            if any(result)
                %result = [1; 1];
            end
        end
    end
end