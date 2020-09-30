classdef AgentGlobalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties (Dependent)
        error_threshold;
    end
    
    methods
        function obj = AgentGlobalEventTrigger(id, x0)
            obj@ConsensusMAS.Agent(id, x0);
        end
        
        function error_threshold = get.error_threshold(obj)
            z = 0;
            for leader = obj.leaders
                z = z - leader.weight*(obj.x - leader.agent.x);
            end
            k = 1/0.6325;
            error_threshold = k * abs(z);
        end
        
        
        function result = trigger(obj)
            result = obj.error > obj.error_threshold;
        end
    end
end