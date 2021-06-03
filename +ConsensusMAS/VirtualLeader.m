classdef VirtualLeader < ConsensusMAS.Agent
    % This class represents an event-triggered agent
    
    methods
        function obj = VirtualLeader(id, states, Af, Bf, controller, c_struct, numstates, numinputs, x0, delta, setpoint, CLK, wind_states)
            obj@ConsensusMAS.Agent(id, states, Af, Bf, controller, c_struct, numstates, numinputs, x0, delta, setpoint, CLK, wind_states);
            
            obj.virtual = true;
            obj.stepall = true;
        end
        
        function step(obj)
            obj.t = obj.t + obj.CLK;
            obj.x = obj.fx(obj.x, obj.t);
        end
        
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = zeros(size(obj.x));
        end
    end
end