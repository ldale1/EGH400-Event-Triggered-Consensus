classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a fixed-triggered agent
    % TODO: make this the superclass
    
    properties
        ERROR_THRESHOLD;
    end
    
    methods
        function obj = AgentFixedTrigger(id, A, B, C, D, K, x0, delta, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, CLK);
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