classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a fixed-triggered agent
    % TODO: make this the superclass
    
    properties
        ERROR_THRESHOLD;
    end
    
    methods
        function obj = AgentFixedTrigger(id, A, B, C, D, K, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, setpoint, CLK);
        end
        
        function error = error(obj) 
            % Difference from last broadcast
            error = zeros(size(obj.x));
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            error_threshold = zeros(size(obj.x));
        end
        
        function triggers = triggers(obj)
            triggers = ones(size(obj.x));
        end
        
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, zeros(size(obj.x))];
        end
    end
end