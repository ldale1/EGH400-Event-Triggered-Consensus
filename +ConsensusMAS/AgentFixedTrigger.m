classdef AgentFixedTrigger < ConsensusMAS.Agent
    % This class represents a fixed-triggered agent
    % TODO: make this the superclass
    
    properties
        ERROR_THRESHOLD;
    end
    
    methods
        function obj = AgentFixedTrigger(id, model_struct, controller, c_struct, s_struct, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, model_struct, controller, c_struct, s_struct, x0, delta, setpoint, CLK);
        end
        
        function error = error(obj) 
            % Difference from last broadcast
            error = zeros(size(obj.x));
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            error_threshold = zeros(size(obj.x));
        end
        
        function triggers = triggers(obj)
            triggers = ones(size(obj.x));
        end
        %{
        function setinput(obj)
            
            z = obj.ConsensusTarget();
            
            for i = 1:length(z)
                z(i) = abs(z(i))^0.8*sign(z(i));
            end
            
            obj.u = -obj.K(obj.x) * z;
        end
        %}
        
        %{
        function setinput(obj)
            m = 0.5;
            J = 0.0112;
            g = 9.8;
            l = 0.2;

            x = obj.x(1);
            vx = obj.x(2)/m;
            y = obj.x(3);
            vy = obj.x(4)/m;
            theta = obj.x(5);
            vtheta = obj.x(6);
            
            %{
            refs = obj.ConsensusTarget();
            refs = refs + 0.3*(obj.x - [1; 1; 1; 1; 1; 0]);
            
            refs = [1; 1; 1; 1; 1; 1];
            
            x_ref = refs(1);
            vx_ref = refs(2);
            y_ref = refs(3);
            vy_ref = refs(4);
            t_ref = refs(5);
            vt_ref = refs(6);
            %}
            
            refs = obj.ConsensusTarget();
            
            vx_ref = refs(2);
            vy_ref = refs(4);
            
            x_ref = 1;%refs(1);% + vx_ref * obj.CLK;
            y_ref = 1;%refs(3) + vy_ref * obj.CLK;
            
            % Gainz
            kx=.5;
            ky=.5;
            kt=5;
            kvx=.1;
            kvy=1;
            kvt=5;
            
            %
            vx_ref = (x_ref - x)*kx;
            theta_ref = -(vx_ref - vx)*kvx;
            vtheta_ref = (theta_ref - theta)*kt;
            u1 = (vtheta_ref - vtheta)*kvt;
            
            u2 = cos(theta);
            
            vy_ref = (y_ref - y)*ky;
            u3 = (vy_ref - vy)*kvy + m*g;
            
            Ff = u3/(2*u2) + u1/(2*l);
            Fr = u3/(2*u2) - u1/(2*l);
            
            obj.u = [Ff; Fr];
            
            if obj.t > 15;
               a = 1; 
            end
        end
        %}
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, zeros(size(obj.x))];
        end
    end
end