classdef AgentFiniteA < ConsensusMAS.Agent
    % This class represents a network agent
    
    properties
        k;
        ERROR_THRESHOLD;
    end
    
    properties (Dependent)
        L;
        Y;
        E;
        Z;
    end
    
    methods
        function obj = AgentFiniteA(id, states, numstates, numinputs, K, x0, delta, setpoint, CLK, wind_states)
            obj@ConsensusMAS.Agent(id, states, numstates, numinputs, K, x0, delta, setpoint, CLK, wind_states);
            
            % Event triggering constant
            obj.k = 0;
            %{
            switch (id)
                case 1
                    obj.K = 2;
                case 2
                    obj.K = 1;
                case 3
                    obj.K = 3;
                case 4
                    obj.K = 2;
            end
            %}
        end
        
        function set.L(obj, L)
            obj.k = 1/max(eig(L));
        end
        
        function Z = get.Z(obj)
            Z = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                Z = Z - leader.weight*(...
                    (obj.xhat - xj.xhat) + ...
                    (obj.delta - xj.delta));
            end
        end
        
        function Y = get.Y(obj)
            Y = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                Y = Y - leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta));
            end
        end
        
        function E = get.E(obj)
            E = zeros(size(obj.x));
            for leader = obj.leaders
                xj = leader.agent;
                E = E - leader.weight*(...
                        (obj.error - xj.error));
            end
        end
        
        
        function setinput(obj)
            % Calculate the next control input
            z = obj.ConsensusTarget();
                       
            
            obj.u = sign(z(1) + z(2))^0.5 + z(2);
            
            %beta = 0.2;
            %gamma = 0.8;
            %K = -obj.K(obj.x);
            %obj.u = -beta * sign(K * z) * abs(K * z)^gamma;
        end
        
        function error_threshold = error_threshold(obj)
            % Calculate the error threhsold
            z = zeros(size(obj.x)); 
            for leader = obj.leaders
                xj = leader.agent;
                
                % Consensus summation
                z = z + leader.weight*(...
                    (obj.x - xj.x) + ...
                    (obj.delta - xj.delta) ...
                    );
            end
            
            % Consensus
            error_threshold = 0.5 * abs(z);
        end
     
        function triggers = triggers(obj)
            % Return vector where states cross the error threshold
            triggers = zeros(size(obj.x)) > (abs(obj.Z - obj.Y) - 0.5 * abs(obj.Y));
            
            
            %{
            triggers = (obj.error > obj.error_threshold);
            if any(triggers)
                triggers = ones(size(obj.x));
            end
            %}
        end
        
        function save(obj)
            % Record current properties
            save@ConsensusMAS.Agent(obj);
            obj.ERROR_THRESHOLD = [obj.ERROR_THRESHOLD, obj.error_threshold];
        end
    end
end