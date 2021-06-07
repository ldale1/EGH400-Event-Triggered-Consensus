classdef AgentLocalEventTrigger < ConsensusMAS.Agent
    % This class represents a network agent
    
    properties
        c;
        alpha;
        ERROR_THRESHOLD;
        
        G;
        H;
        K;
    end
    
    properties (Dependent)
        F;
    end
    
    methods
        function obj = AgentLocalEventTrigger(id, model_struct, controller, c_struct, sim_struct, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, model_struct, controller, c_struct, sim_struct, x0, delta, setpoint, CLK);
            
            if model_struct.linear
                A = model_struct.Af(c_struct.x_op, c_struct.u_op);
                B = model_struct.Bf(c_struct.x_op, c_struct.u_op);
                [obj.G, obj.H] = c2d(A, B, obj.CLK);
                
                obj.K = dlqr(obj.G, obj.H, c_struct.Q, c_struct.R);
            else
                error("Not implemented nonlinear yet")
            end
            
            
            % Event triggering constant
            obj.c = 0.5;
            obj.alpha = 0.999;
        end
        
        function set.F(obj, F)
            % Change the exponential power
            I = eye(size(F, 1));
            J = jordan(I - F);

            % Calculate Xi matrix
            I1 = eye(size(F,1)-1);
            delta = J(2:end, 2:end);
            Xi = kron(I1, obj.G) + kron(delta, -obj.H*obj.K);
            eigs_Xi_max = max(eigs(Xi));
            
            if (eigs_Xi_max  > 1)
            	fprintf("Max Xi eigenvalue %.2f too large", eigs_Xi_max);
            end
            
            obj.alpha = abs(eigs_Xi_max);
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
        
        function error = error(obj) 
            % Difference from last broadcast
            error = norm(obj.xhat - obj.x) * ones(size(obj.x));
            error = floor(abs(error)*1000)/1000;
        end

        function error_threshold = error_threshold(obj)            
            % Consensus
            t = obj.iters * obj.CLK;
            error_val = obj.c * obj.alpha^t;
            error_threshold = ones(size(obj.x)) * error_val;
        end
        
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = (obj.error >= obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            %obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end