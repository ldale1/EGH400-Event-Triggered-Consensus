function SimulateDynamic(obj, type, varargin)
    % Run the network simulation
    % Agents are assigned to lanes
    import ConsensusMAS.*;
    
    function exit_func = DynamicFunc(t, varargin)
        % parse args
        % Unpackage repacked args
        varargin = varargin{1};
        mintime = 0;
        maxtime = 1e5;
        for k = 1:length(varargin)
            if (strcmp(varargin{k}, "mintime"))
                mintime = varargin{k + 1} + t;
            elseif (strcmp(varargin{k}, "maxtime"))
                maxtime = varargin{k + 1} + t;
            end
        end
        exit_func = @(t, c) (...
            ((round(t - mintime, 6) >= 0) && c) ||  t > maxtime);
    end

    function exit_func = FixedFunc(t, varargin)
        % parse args
        % Unpackage repacked args
        % TODO: Fix this up... shouldn't need args
        varargin = varargin{1};
        endtime = t;
        for k = 1:length(varargin)
            if (strcmp(varargin{k}, "time"))
                endtime = varargin{k + 1} + t;
            end
        end
        exit_func = @(t, c) (round(t - endtime, 6) >= 0);
    end

    % Get an exit function
    if (strcmp(type, "Dynamic"))
        exit_func = DynamicFunc(obj.t, varargin);
    elseif (strcmp(type, "Fixed"))
        exit_func = FixedFunc(obj.t, varargin);
    else
        error("Unrecognised type")
    end
    
    % Iterations without spawning agent
    spawn_limit = 5;
    unspawned = 0;
    pseudo_chance = 5; % inverse of this
    
    
    global x_generator
        
    % Simulate
    while (true)
        
        
        ALL_X = [obj.agents.x];
        agent_lanes = round(ALL_X(4,:));
        
        
        % Between lanes 1 and 5
        agent_lanes = max(agent_lanes, 1);
        agent_lanes = min(agent_lanes, 5);
        
        % Make a set
        lanes = unique(agent_lanes);
        
        
        if (unspawned > spawn_limit) && (mod(randi(pseudo_chance), pseudo_chance) == 0)
            
            ref = [0; 0; 0; 0; 0; 0; 0; 0];
            set = [NaN; NaN; NaN; 0; 0; 0; NaN; NaN];
            
            obj.SIZE = obj.SIZE + 1;
            
            new_x = x_generator();
            counts = hist(agent_lanes, 1:5);
            [~, min_lane] = min(counts);
            new_x(4) = min_lane + (rand()-0.5)/2;

            obj.agents = [...
                obj.agents, ...
                obj.agent_generator(obj.SIZE, new_x, ref, set)];
            
            unspawned = 0;
        else
            unspawned = unspawned + 1;
        end
        
        
        % Empty adjacency, fill it
        ADJ = zeros(obj.SIZE);
        for lane = lanes
            % Get the agents in a current lane
            in_lane = obj.agents(find(agent_lanes == lane));
            
            % What are their current values
            X = [in_lane.x];
            
            % Get the state indeces
            [~, ind] = sort(X, 2);
            
            % Sort indeces by state 1
            sort_ind = ind(1,:);
            for i = 1:length(in_lane)
                base = in_lane(sort_ind(i));

                % Give them a separation
                if (i == 1)
                    base.delta = [0; 0; 0; 0; 0; 0; 0; 0];
                else
                    % Add communication with the previous agent
                    prev = in_lane(sort_ind(i - 1));
                    ADJ(base.id, prev.id) = 1;
                    ADJ(prev.id, base.id) = 1;
                    
                    % Relative offsets
                    mindelta = max(abs(prev.x - base.x), [3; 0; 0; 0; 0; 0; 0; 0]) .* [1; 0; 0; 0; 0; 0; 0; 0];
                    base.delta = prev.delta - mindelta;
                end
                base.setpoint = [NaN; NaN; NaN; agent_lanes(base.id); 0; 0; NaN; NaN];
            end
        end
        
        if any(size(ADJ) ~= size(obj.ADJ)) || any(reshape(ADJ ~= obj.ADJ, [], 1))
            obj.ADJ = ADJ;
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
        
        % Step accordingly
        for agent = obj.agents
            agent.step();
        end 
        
        % exogenous disturbanece
        for agent = obj.agents
            wind = obj.ts * agent.Dw * -obj.wind_model.forces(agent);
            agent.x = agent.x + wind;
        end

        % Move agent recieve buffers
        for agent = obj.agents
            agent.shift_receive()
        end
        
        % Next wind stage
        obj.wind_model.step()

        obj.t = obj.t + obj.ts;

        % Check the exit conditions
        if exit_func(obj.t, obj.consensus)
            break;
        end
    end
    
    
    % Agents added late need padding with NaNs
    iterations = length(obj.T);
    for agent = obj.agents
        iterations_agent = agent.iters;
        if iterations > iterations_agent
            padding = iterations - iterations_agent;
           agent.X = [NaN*zeros(size(agent.x, 1), padding), agent.X];
           agent.U = [NaN*zeros(size(agent.u, 1), padding), agent.U];
           agent.TX = [zeros(size(agent.x, 1), padding), agent.TX];
           agent.ERROR = [NaN*zeros(size(agent.x, 1), padding), agent.ERROR];
           agent.ERROR_THRESHOLD = [NaN*zeros(size(agent.x, 1), padding), agent.ERROR_THRESHOLD];
        end
    end
end