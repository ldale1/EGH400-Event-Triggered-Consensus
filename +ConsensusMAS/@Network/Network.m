classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        F;
        agents;
        T;
    end
    properties (Dependent)
        SIZE;
        t;
        x;
        x0;
    end
    
    methods
        function obj = Network(A, X0)
            import ConsensusMAS.*;
            % Create the matrices
            SIZE = length(X0);
            obj.F = (eye(SIZE) + diag(sum(A, 2)))^-1 * (eye(SIZE) * A);
            
            % Create the agents
            agents = Agent.empty(SIZE, 0);
            for n = 1:SIZE
                agents(n) = Agent(n, X0(n));
            end
            
            % Create the network
            for i = 1:SIZE % row-wise
                for j = 1:SIZE %column-wise
                    weight = obj.F(i, j);
                    if (i~=j && weight ~= 0)
                        agents(i) = agents(i).addReceiver(weight, agents(j));
                    end
                end
            end
            obj.agents = agents;
        end
        
        function set.t(obj, t); obj.T = [obj.T t]; end
        function t = get.t(obj); t = obj.T(end); end
        function x0 = get.x0(obj)
            x0 = zeros(obj.SIZE, 1);
            for i = 1:obj.SIZE
                x0(i) = obj.agents(i).X(1);
            end
        end
        function x = get.x(obj)
            x = zeros(obj.SIZE, 1);
            for i = 1:obj.SIZE
                x(i) = obj.agents(i).X(end);
            end
        end
        function SIZE = get.SIZE(obj); SIZE = length(obj.agents); end
        
        function PlotGraph(obj)
            figure();
            plot(digraph(obj.F'));
            title('Graph')
        end
        
        function PlotStates(obj)
            figure();
            hold on;
            for n = 1:obj.SIZE
                plot(obj.T, obj.agents(n).X, 'DisplayName', obj.agents(n).name)
            end
            xlim([obj.T(1) obj.T(end)]);
            title('Agents')
            legend()
        end
    end
    
    methods (Abstract)
        Simulate(obj, varargin)
    end
end