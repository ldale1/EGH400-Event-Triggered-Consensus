classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a fixed-triggered agent
    
    properties
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentFixedTrigger(id, A, B, C, D, CLK, x0)
            obj@ConsensusMAS.Agent(id, A, B, C, D, CLK, x0);
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