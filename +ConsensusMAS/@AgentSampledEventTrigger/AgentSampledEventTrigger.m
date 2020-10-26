classdef AgentSampledEventTrigger < ConsensusMAS.Agent
    % This class represents an event-triggered agent
    
    properties
        sigma;
        phi;
        theta;
        
        
        ERROR_THRESHOLD;
    end

    
    methods
        function obj = AgentSampledEventTrigger(id, A, B, C, D, K, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, A, B, C, D, K, x0, delta, setpoint, CLK);
            
            switch(id)
                case 1
                    sigma = 0.010;
                case 2
                    sigma = 0.005;
                case 3
                    sigma = 0.010;
                case 4
                    sigma = 0.015; 
            end
            obj.sigma = sigma;
            obj.theta = 0.005;
            obj.phi = [0.0005, 0.0017;
                       0.0017 0.0067];
                   
            % Override
            %obj.xhat = zeros(size(x0));
        end
        
        function error = error(obj) 
            % Difference from last broadcast
            error = obj.xhat - obj.x;
            
            error = (error' * obj.phi * error) ;
            error = error * ones(size(obj.x));
            
        end
        
        function step(obj)      
            step@ConsensusMAS.Agent(obj);
            
            % Project forwards, without input
            %obj.xhat = obj.G * obj.xhat;
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
            error_threshold = (obj.sigma *  z' * obj.phi * z) * ones(size(obj.x));
        end
     
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error > obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end