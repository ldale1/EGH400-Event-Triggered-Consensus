classdef AgentSMC < ConsensusMAS.Agent
    % This class represents a fixed-triggered agent
    % TODO: make this the superclass
    
    properties
        ERROR_THRESHOLD;
    end
    
    methods
        function obj = AgentSMC(id, model_struct, controller, c_struct, x0, delta, setpoint, CLK)
            obj@ConsensusMAS.Agent(id, model_struct, controller, c_struct, x0, delta, setpoint, CLK);
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
        
        % OVERRIDE
        function setinput(obj)
            % Calculate the next control input
            %x = obj.x;%ConsensusTarget();
            x = obj.ConsensusTarget();
           
            %{
            c = [0.5 1];
            %A = [-5 -10; 2 5];
            A = [0 1; 
                  4 5];
            B = [0; 1];
            
            T = [1 -1; 0 1];
            %T = [-0.8944 -0.4472; -0.4472 0.8955];
            
            z = T*x; %T * x;
            
            s = c * z;
            
            u = -(c * B)^-1* (c * A * z + 1.5*sign(s));
            %}
            c = [1.5 1];
            s = c * x;
            u = -[0 0.5]*x-1.4 *sign(s);
            
            obj.u = u;%:sign(z(1) + z(2))^0.5 + z(2);
        end
        
        function save(obj)  
            save@ConsensusMAS.Agent(obj);
            obj.ERROR = [obj.ERROR, obj.error];
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, zeros(size(obj.x))];
        end
    end
end