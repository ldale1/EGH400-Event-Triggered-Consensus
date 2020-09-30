classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    
    
    
    
    methods
        function obj = AgentFixedTrigger(id, x0)
            obj@ConsensusMAS.Agent(id, x0);
        end
        
        function result = trigger(obj)
            result = true;
        end
    end
    
    
end