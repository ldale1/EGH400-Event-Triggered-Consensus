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
        function obj = AgentLocalEventTrigger(id, A, B, C, D, x0, ADJ)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
            
            % Event triggering constant
            D = diag(sum(ADJ, 2));
            L = D - ADJ;
            %I = eye(size(ADJ, 1));
            %Ln = (I + D)^-1*L;
            %F = (I + D)^-1 * (I * ADJ);
            obj.k = 1/max(eig(L));
        end
        
        function error_threshold = get.error_threshold(obj)
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                z = z + leader.weight*(obj.xhat - leader.agent.xhat);
            end
            error_threshold = [0 0];
        end
        
        
        function triggers = triggers(obj)
            triggers = obj.error > obj.error_threshold;
            if any(triggers)
                % TODO: need to determine if all states are broadcast
                %       on a single state trigger
                %triggers = ones(size(obj.x));
            end
        end
        
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end