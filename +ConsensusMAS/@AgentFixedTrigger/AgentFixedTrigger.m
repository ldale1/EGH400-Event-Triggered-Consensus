classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    properties
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentFixedTrigger(id, A, B, C, D, x0)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
        end
        
        function triggers = triggers(obj)
            triggers = ones(size(obj.x));
        end
        
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, zeros(size(obj.x))];
        end
    end
end