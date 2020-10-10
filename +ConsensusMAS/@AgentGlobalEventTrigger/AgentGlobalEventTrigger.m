classdef AgentGlobalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    
    methods
        function obj = AgentGlobalEventTrigger(id, A, B, C, D, x0, L)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
            
            % Event triggering constant
            obj.k = 1/max(eig(L));
            
            % Could iterate to find more exact eigenvalue
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                        obj.x - ...
                        xj.x);
                
                %{
                z = z + leader.weight*(...
                        obj.A^obj.txt * obj.x - ...
                        xj.A^xj.txt * xj.x);
                %}
            end
            
            % Exact consensus
            error_threshold = obj.k * abs(z);
            
            % Quantised representation (bounded consensus)
            error_threshold = ceil(error_threshold * 1e2)/1e2;
        end
        
        
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error > obj.error_threshold);% .* [0; 1];
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end