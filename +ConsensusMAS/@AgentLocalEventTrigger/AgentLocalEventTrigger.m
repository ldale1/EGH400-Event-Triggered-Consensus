classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    
    methods
        function obj = AgentLocalEventTrigger(id, A, B, C, D, CLK, x0, L)
            obj@ConsensusMAS.Agent(id, A, B, C, D, CLK, x0);
            
            % Event triggering constant
            obj.k = 1/max(eig(L));
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                        obj.x - xj.x);
                    
                % need a way to describe z1 in terms of z2
                % set [1; 1]
                
            end
            
            % Consensus
            error_threshold = obj.k * abs(z);
        end
        
        
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error > obj.error_threshold);
            if any(triggers)
                triggers = [1;1];
            end
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end