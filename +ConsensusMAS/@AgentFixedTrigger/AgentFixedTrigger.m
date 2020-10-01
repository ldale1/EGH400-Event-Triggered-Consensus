classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    methods
        function obj = AgentFixedTrigger(id, A, B, C, D, x0)
            obj@ConsensusMAS.Agent(id, A, B, C, D, x0);
        end
        
        function result = trigger(obj)
            result = ones(size(obj.x));
        end
    end
end