classdef AgentGlobalEventTrigger < ConsensusMAS.Agent
    % This class represents an event-triggered agent
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        L;
    end
    
    methods
        function obj = AgentGlobalEventTrigger(id, states, Af, Bf, controller, c_struct, numstates, numinputs, x0, delta, setpoint, CLK, wind_states)
            obj@ConsensusMAS.Agent(id, states, Af, Bf, controller, c_struct, numstates, numinputs, x0, delta, setpoint, CLK, wind_states);
            
            % Override
            obj.xhat = zeros(size(x0));
            
            % Event triggering constant
            obj.k = 0;
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        function error = error(obj) 
            % Difference from last broadcast
            error = obj.xhat - obj.x;
            
            % Quantise
            error = floor(abs(error)*1000)/1000;
        end
        
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            % Project forwards, without input
            obj.xhat = obj.xhat + obj.fx(obj.xhat, zeros(obj.numinputs, 1))*obj.CLK;
            
            % Estimate other agents
            for i = 1:length(obj.transmissions_rx)
                leader = obj.transmissions_rx(i).agent;
                transmission = obj.transmissions_rx(i).xhat;
                obj.transmissions_rx(i).xhat = ...
                    transmission + ...
                    leader.fx(transmission, zeros(leader.numinputs, 1))*leader.CLK;
            end
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta));
            end
            
            % Consensus
            error_threshold = obj.k * norm(abs(z));
            error_threshold = error_threshold * ones(size(obj.x));
        end
     
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (norm(obj.error)* ones(size(obj.x)) > obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end  
        end
        
        %{
        function setinput(obj)
            z = obj.ConsensusTarget();
            for i = 1:length(z)
                z(i) = abs(z(i))^2*sign(z(i));
            end
            obj.u = -[1 1] * z;
        end
        %}
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end