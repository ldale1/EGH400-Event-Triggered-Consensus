classdef Network < ConsensusMAS.RefClass
    % This class represents a network agent
    % Inherits from superclass handle so that it is passed by reference
    
    properties
        type;
        TOPS;           % Network topologies vector
        SIZE;           % network size
        
        agents;         % network agents
        virtual_agents;
        
        agentstates;        % How many states on agents
        agentinputs;        % How many inputs on agents
        agent_generator;    % Agent factory
        
        sim_struct;         % Agent simulation data
        
        T;  % times vector
        ts; % time steps
        
        wind;
        
        controller;
    end
    properties (Dependent)
        ADJ; % adjacency matrix
        t; % current time instant
        ss;
    end
    
    methods (Static)
        function gen = AgentGenerator(type, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ts)
            
            % Curry agent creation for dynamic simulation
            import ConsensusMAS.*;
            switch type
                case ImplementationsEnum.FixedTrigger
                    gen = @(n, x, delta, sp) ...
                        AgentFixedTrigger( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, delta, sp, ts);
                
                case ImplementationsEnum.GlobalEventTrigger_Base
                    gen = @(n, x, delta, sp) ...
                        AgentGlobalEventTrigger_Base( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, delta, sp, ts);        
                        
                case ImplementationsEnum.GlobalEventTrigger
                    gen = @(n, x, delta, sp) ...
                        AgentGlobalEventTrigger( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, delta, sp, ts);
                        
                case ImplementationsEnum.GlobalEventTrigger_Aug
                    gen = @(n, x, delta, sp) ...
                        AgentGlobalEventTrigger_Aug( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, delta, sp, ts);
                        
                case ImplementationsEnum.LocalEventTrigger
                    gen = @(n, x, delta, sp) ...
                        AgentLocalEventTrigger( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, delta, sp, ts);
                    
                case ImplementationsEnum.ETSMC
                    gen = @(n, x, delta, sp) ...
                        AgentSMC( ... 
                            n, model_struct, ...
                            controller, controller_struct, ...
                            sim_struct, ...
                            x, 0, 0, ts);
                                       
                otherwise
                    error("Unrecognised type");
            end
        end
    end
    
    methods
        function obj = Network(type, model_struct, ...
                controller, controller_struct, ...
                sim_struct, ...
                X0, delta, setpoint, ts)
        
            % Network constructor
            import ConsensusMAS.*;
            import ConsensusMAS.Utils.*;
            
            % Store
            obj.type = type;
            obj.SIZE = size(X0, 2);
            obj.t = 0;
            obj.ts = ts;
            obj.agentstates = model_struct.numstates;
            obj.agentinputs = model_struct.numinputs;
            
            obj.controller = controller;
            
            obj.sim_struct = sim_struct;
            
            % Generate agents
            obj.agent_generator = Network.AgentGenerator(...
                type, model_struct, ...
                controller, controller_struct, ...
                sim_struct, ts);
            
            obj.agents = arrayfun(@(x) ...
                obj.agent_generator(x, X0(:,x),  delta(x),  setpoint(x)), ...
                1:obj.SIZE);
            
            % Save their initial values
            for agent = obj.agents
                agent.save()
            end
            
            global wind
            obj.wind = wind;
        end
        
        
        function set.t(obj, t)
            % Setting time udpates times vector
            obj.T = [obj.T t]; 
        end
        function t = get.t(obj)
            % Get latest time
            t = obj.T(end); 
        end
        
        function ss = get.ss(obj)
            ss = obj.sim_struct;
        end
        
        function set.ADJ(obj, ADJ)
            % Create the network
            import ConsensusMAS.*;
            import ConsensusMAS.Utils.*;

            % Frobenius discrete time RS matrix
            L = GraphLaplacian(ADJ);
            F = GraphFrobenius(ADJ);

            % Cleanse connections
            for agent = obj.agents
                agent.leaders = [];
                agent.followers = [];
                agent.transmissions_rx = [];
                
                switch obj.type                        
                    case {ImplementationsEnum.GlobalEventTrigger, ...
                            ImplementationsEnum.GlobalEventTrigger_Base, ...
                            ImplementationsEnum.GlobalEventTrigger_Aug}
                        agent.L = L;
                        
                    case ImplementationsEnum.LocalEventTrigger
                        agent.F = F;
                        
                    otherwise
                        %
                end
            end
            
            for i = 1:obj.SIZE % row-wise
                for j = 1:obj.SIZE %column-wise
                    weight = F(i, j);
                    if (i~=j && weight ~= 0)
                        obj.agents(j).addReceiver(obj.agents(i), weight);
                    end
                end
            end
            
            % This isn't saved !
            % TODO: This be wrong
            for agent = obj.agents
                agent.tx = ones(size(agent.x));
                agent.sample()
                agent.broadcast()
            end
            
            for agent = obj.agents
                agent.check_receive()
            end
            
            % Storing topology
            top.t = obj.t;
            top.ADJ = ADJ;
            obj.TOPS = [obj.TOPS top]; 
        end
        
        function ADJ = get.ADJ(obj)
            try
                ADJ = obj.TOPS(end).ADJ; 
            catch
                ADJ = zeros(obj.SIZE);
            end
        end
        
        function add_leader(obj, states, numstates, x0)
            import ConsensusMAS.VirtualLeader;
            
            virtual_leader = VirtualLeader(99999, states, NaN,  NaN, NaN,  NaN, ...
                 numstates,  1, x0,  zeros(numstates, 1),  NaN, ...
                 obj.ts,  []);
            virtual_leader.save(); 
            
            for agent = obj.agents
                virtual_leader.addReceiver(agent, 1);
            end
             
            obj.virtual_agents = [obj.virtual_agents virtual_leader];
        end
        
        function consensus = consensus(obj)
            % Checks whether the network has reached consensus
            % If at consensus should not have a control input
            u = ones(obj.agentinputs, 1, obj.SIZE);
            
            for agent = obj.agents
                u(:,:,agent.id) = agent.u;
            end
            consensus = all(all(abs(u) < 1e-2));
        end
        
        function final_value = final_value(obj)
            % Gets the current average of current states
            if ~obj.consensus
                error("This network has not reached consensus.");
            else
                final_value = mean([obj.agents.x]); 
            end
        end
       
        function assign_formation(obj)
            %{
            X = [obj.agents.x];
            
            dx_avg = mean(X(2,:));
            dy_avg = mean(X(4,:));
            theta = atan2(dy_avg, dx_avg);
          
            
            x_base = @(id) 10 * abs(id - (obj.SIZE + 1)/2);
            y_base = @(id) 10 * ((obj.SIZE + 1)/2 - id);
            
            
            x = @(id) x_base(id)*cos(theta) - y_base(id)*sin(theta);
            y = @(id) x_base(id)*sin(theta) + y_base(id)*cos(theta);
            
            
            ref = @(id) [x(id); 0; y(id); 0; 0; 0];
            
            for agent = obj.agents
                agent.delta = ref(agent.id);
            end
            %}
        end
        
        
        function sim_step(obj)
            %{
            % Step accordingly
            for agent = obj.virtual_agents
                agent.save();
                agent.broadcast();
                agent.step();
            end 
            %}
            
            
            if obj.t > 6.3
                a =1;
            end
            % Broadcast agents if needed
            for agent = obj.agents
                agent.check_trigger();
            end

            % Check for an incoming transmission
            for agent = obj.agents
                agent.check_receive()
            end 

            % Have agents save their data
            for agent = obj.agents
                agent.save();
            end
            
            % Time
            obj.t = obj.t + obj.ts;

            % Step accordingly
            for agent = obj.agents
                agent.set_controller();
            end
            
            % Step accordingly
            for agent = obj.agents
                agent.step();
            end

            % Move agent recieve buffers
            for agent = obj.agents
                agent.shift_receive()
            end

            % Next wind stage
            obj.wind.step()
        end
        
        % Simulate network
        Simulate(obj, varargin);
        SimulateDynamic(obj, varargin);
        
        % Graph Figures
        PlotEigs(obj, varargin);
        PlotGraph(obj, varargin);
        
        % Basic Figures
        PlotInputs(obj, varargin);
        PlotStates(obj, varargin);
        PlotCompact(obj, varargin);
        PlotTriggers(obj, varargin);
        
        % Complex Subplot Figures
        PlotErrors(obj, varargin);
        PlotErrorsNorm(obj, varargin);
        Plot3(obj, varargin)
        PlotTriggersStates(obj,varargin);
        PlotTriggersInputs(obj, varargin);
        
        % Animation
        Animate(obj, varargin);
    end
    
    methods(Static)
        colors = GetColors(ncolors);
       
        function NetworkCompareError(network_map)
            ind = 1;
            plots = {};

            plots_peak = 0;
            for key = network_map.keys
                network = network_map(cell2mat(key));

                Xs = zeros(network.SIZE, length(network.T));
                for ii = 1:network.SIZE
                    Xs(ii,:) = sum(network.agents(ii).ERROR.^2);
                    Xs(ii,1) = 0;
                end

                % Sqrt the sum squares
                actual = smoothdata(sqrt(sum(Xs).^2));

                % Save for normalisation
                plots(ind) = {[network.T', actual']};
                ind = ind + 1;

                plots_peak = max(plots_peak, max(actual));
                %plot(network.T, actual/max(actual), "DisplayName", cell2mat(key));
            end      

            figure(), hold on;
            for i = 1:length(plots)
                store = cell2mat(plots(i));
                time = store(:,1);
                vals = store(:,2)/plots_peak;
                plot(...
                    time, vals ...
                );
            end
            
            keys = strrep(network_map.keys,'_','');
            keys = strrep(keys,'GlobalEventTrigger-','GlobalEventTrigger-Modelbased-');
            keys = strrep(keys,'-PolePlacement','');
            keys = strrep(keys,'rBase','r');
            legend(keys)
            
            
            %legend(network_map.keys);
            grid on;

            title("Error Norm Comparison")
            xlabel("Time (s)")
            ylabel("Error L2 Norm")
        end
       
       
        function NetworkCompareAgents(network_map, varargin)
            %figure(), hold on;
            %{
            for key = network_map.keys
                network = network_map(cell2mat(key));

                Xs = zeros(network.agentstates, length(network.T));
                for ii = 1:network.agentstates
                    xs = zeros(network.SIZE, length(network.T));

                    for iii = 1:network.SIZE
                        xs(iii,:) = network.agents(iii).X(ii,:);
                    end

                    Xs(ii,:) = std(xs);
                end

                plot(network.T, Xs);
            end
            grid on;
            %}
            i = 1;
            plots = cell(length(network_map), 1);
            plots_peak = 0;
            for key = network_map.keys
                network = network_map(cell2mat(key));
                Xs = zeros(network.agentstates, length(network.T));
                for ii = 1:network.agentstates
                    xs = zeros(network.SIZE, length(network.T));
                    for iii = 1:network.SIZE
                        xs(iii,:) = network.agents(iii).X(ii,:);
                    end
                    Xs(ii,:) = std(xs);
                end

                consensus_l2 = sqrt(sum(Xs.^2));
                
                plots_peak = max(plots_peak, max(consensus_l2));
                plots(i) = {[network.T', consensus_l2']};
                i = i + 1;
            end
            
            
            plottype = "none";
            for k = 1:length(varargin)
                if (strcmp(varargin{k}, "plottype"))
                    k = k + 1;
                    plottype = varargin{k};
                end
            end
            
            switch plottype
                case "reuse"
                    plotstyle = "--";
                    legend_extra = "-Consensus";
                    gcf; hold on;
                    
                otherwise
                    plotstyle = "-";
                    legend_extra = "";
                    figure(), hold on;
            end
             
            
            network_map_keys = network_map.keys;
            for i = 1:length(plots)
                store = cell2mat(plots(i));
                time = store(:,1);
                vals = store(:,2)/plots_peak;
                legend_name = strrep(cell2mat(network_map_keys(i)) ,'_', '') + legend_extra;
                plot(...
                    time, vals , plotstyle, 'DisplayName', legend_name  ...
                );
            end
            
            keys = strrep(network_map.keys,'_','');
            keys = strrep(keys,'GlobalEventTrigger-','GlobalEventTrigger-Modelbased-');
            keys = strrep(keys,'-PolePlacement','');
            keys = strrep(keys,'rBase','r');
            legend(keys + legend_extra);
            grid on;

            title("Average Consensus Deviation")
            xlabel("Time (s)")
            ylabel("Value")
        end
    end
end