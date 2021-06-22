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
    global x_generator;
    spawn_limit = 5;
    unspawned = 0;
    pseudo_chance = 5; % inverse of this
    
    
    number_lanes = 1;
    lane_gap = 20;
    interlane_gap = 0;
    
    %sp = @(obj, lane)
    function sp = getSetPoint(numstates, y_state, vy_state, lane)
        sp = NaN * zeros(numstates, 1);
        
        %sp(y_state) = lane;
        %sp(vy_state) = 0;
        sp(6) = 0;
    end
    
    % Simulate
    while (true)
        ALL_X = [obj.agents.x];
        agent_lanes = round(ALL_X(obj.ss.y_state,:) / lane_gap)*lane_gap;
        
        % Between lanes 1 and 5
        agent_lanes = max(agent_lanes, 1*lane_gap);
        agent_lanes = min(agent_lanes, number_lanes*lane_gap);
        
        % Make a set
        lanes = unique(agent_lanes) ;
        
        %{
        if (unspawned > spawn_limit) && (mod(randi(pseudo_chance), pseudo_chance) == 0)
            
            ref = zeros(obj.agentstates, 1); %[0; 0; 0; 0; 0; 0; 0; 0];
            set = getSetPoint(obj.agentstates, obj.ss.y_state, obj.ss.vy_state, 0);
            
            obj.SIZE = obj.SIZE + 1;
            
            new_x = x_generator();
            
            counts = hist(agent_lanes, 1:5);
            [~, min_lane] = min(counts);
            new_x(obj.ss.y_state) = min_lane + (rand()-0.5)/2;

            obj.agents = [...
                obj.agents, ...
                obj.agent_generator(obj.SIZE, new_x, ref, set)];
            
            unspawned = 0;
        else
            unspawned = unspawned + 1;
        end
        %}
        
        % Empty adjacency, fill it
        ADJ = zeros(obj.SIZE);
        for lane = lanes
            % Get the agents in a current lane
            in_lane = obj.agents(find(agent_lanes == lane));
            
            % What are their current values
            X = [in_lane.x];
            X = X(obj.ss.x_state,:);
            
            % Get the state indeces
            [~, ind] = sort(X, 2);
            
            % Sort indeces by state 1
            sort_ind = ind;
            for i = 1:length(in_lane)
                base = in_lane(sort_ind(i));

                % Give them a separation
                if (i == 1)
                    base.delta = zeros(base.numstates, 1);
                else
                    % Add communication with the previous agent
                    prev = in_lane(sort_ind(i - 1));
                    ADJ(base.id, prev.id) = 1;
                    ADJ(prev.id, base.id) = 1;
                    
                    % Relative offsets - we are only doing this in the x 
                    x_diff = abs(prev.x(prev.ss.x_state) - base.x(base.ss.x_state));
                    min_x_delta = max(x_diff, interlane_gap);
                    
                    min_x_delta = interlane_gap;
                    
                    
                    % For the current agent
                    % delta = max(abs(prev.x - base.x), [3; 0; 0; 0; 0; 0; 0; 0]) .* [1; 0; 0; 0; 0; 0; 0; 0];
                    basedelta = zeros(base.numstates, 1);
                    basedelta(base.ss.x_state) = prev.delta(prev.ss.x_state) - min_x_delta;
                    base.delta = basedelta;
                end
                
                %base.setpoint = [NaN; NaN; NaN; agent_lanes(base.id); 0; 0; NaN; NaN];
                base.setpoint = getSetPoint(base.numstates, base.ss.y_state, base.ss.vy_state, agent_lanes(base.id));
            end
        end
        
        if any(size(ADJ) ~= size(obj.ADJ)) || any(reshape(ADJ ~= obj.ADJ, [], 1))
            obj.ADJ = ADJ;
        end
        
        obj.sim_step;
        %{
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
        
        %{
        % exogenous disturbanece
        for agent = obj.agents
            wind = obj.ts * agent.Dw * -obj.wind_model.forces(agent);
            agent.x = agent.x + wind;
        end
        %}
        
        % Move agent recieve buffers
        for agent = obj.agents
            agent.shift_receive()
        end
        
        % Next wind stage
        obj.wind_model.step()

        obj.t = obj.t + obj.ts;
        %}

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