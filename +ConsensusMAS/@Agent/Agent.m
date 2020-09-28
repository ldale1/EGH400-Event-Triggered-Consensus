classdef Agent < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        id; % Agent ID number
        weights; % Neighbouring weights
        neighbours; % Neighbouring agents
        X; % State array
        U; % Control input array
    end
    properties (Dependent)
        name; % Agent name
        x; % Current state
        u; % Current control input
    end
    
    methods
        function obj = Agent(id, x0)
            % Class constructor
            obj.id = id;
            obj.x = x0;
        end
        
        function name = get.name(obj); name = sprintf("Agent %d", obj.id); end
        
        function set.x(obj, x); obj.X = [obj.X x]; end
        function x = get.x(obj); x = obj.X(end); end
        
        function set.u(obj, u); obj.U = [obj.U u]; end
        function u = get.u(obj); u = obj.U(end); end
        
        function obj = addReceiver(obj, weight, neighbour)
            % Attach a neighbour to this object
            obj.weights = [obj.weights, weight];
            obj.neighbours = [obj.neighbours, neighbour];
        end
        
        function obj = broadcast(obj)
            % Broadcast this object to all its neighbours
            for neighbour = obj.neighbours
                neighbour.recieve(obj);
            end
        end
        
        function obj = recieve(obj, neighbour)
            % Recieve a broadcast from a neighbour notify call
            for  i = 1:length(obj.neighbours)
                if obj.neighbours(i).id == neighbour.id
                    obj.neighbours(i) = neighbour;
                end
            end 
        end
        
        function obj = calculate(obj)
            % Calculate the next control input
            u = 0;
            for n = 1:length(obj.neighbours)
                u = u - obj.weights(n)*(obj.x - obj.neighbours(n).x);
            end
            obj.u = u;
        end
        
        function obj = step(obj, ts)
            % Step the agent
            import ConsensusMAS.*
            obj.x = obj.x + obj.u * ts;
        end
        
    end
end