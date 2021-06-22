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
    spawn_limit = 2;
    unspawned = 0;
    pseudo_chance = 8; % inverse of this
    
    
    number_lanes = 5;
    lane_gap = 20;
    interlane_gap = 2.5;
    
    %sp = @(obj, lane)
    function sp = getSetPoint(numstates, y_state, vy_state, lane)
        sp = NaN * zeros(numstates, 1);
        
        sp(y_state) = lane;
        sp(vy_state) = 0;
        %sp(6) = 0;
    end

    lane_width = 50;
    
    iters = 0;
    reassignments = 0;

    manual_map = containers.Map;
    % Simulate
    while (true)
        iters = iters + 1;
        ALL_X = [obj.agents.x];
        agent_lanes = round(ALL_X(obj.ss.y_state,:) / lane_gap)*lane_gap;
        
        if (randi(500) <= 16)
            reassignments = reassignments + 1;
            
            attempts = 0;
            found = 0;
            while ~found && attempts < 10
                attempts = attempts + 1;
                reassign = randi(obj.SIZE);
                reassigned_agent = obj.agents(reassign);
                pos = reassigned_agent.x(reassigned_agent.ss.x_state);
                
                lane = reassigned_agent.setpoint(reassigned_agent.ss.y_state);
                
                
                if (pos > 5 && pos < 35) && (lane ~= number_lanes*lane_gap)
                    
                    if ~(any(find(str2double(manual_map.keys) == reassign)))
                        %extra = randi(15) == 1;
                        extra= 0;
                        
                        if isnan(lane)
                            new_lane = round(rand()*number_lanes)*lane_gap;
                        elseif lane == 1*lane_gap
                            new_lane = lane + (1 + extra)*lane_gap;
                        elseif lane == number_lanes*lane_gap
                            new_lane = lane - (1 + extra)*lane_gap;
                        else
                            new_lane = lane + randi(1 + extra)*sign(rand()-0.5)*lane_gap;
                        end
                        
                        new_lane = max(new_lane, 1*lane_gap);
                        new_lane = min(new_lane, number_lanes*lane_gap);
        
                        found = 1;
                        manual_map(sprintf("%d", reassign)) = new_lane;
                    end
                end
            end
        end       
        
        for reassigned_key = manual_map.keys
            reassigned_index = str2double(reassigned_key);
            agent_lanes(reassigned_index) = manual_map(reassigned_key{:});
        end
        
        % Between lanes 1 and 5
        agent_lanes = max(agent_lanes, 1*lane_gap);
        agent_lanes = min(agent_lanes, number_lanes*lane_gap);
        
        % Make a set
        lanes = unique(agent_lanes) ;
        if (unspawned > spawn_limit) && (mod(randi(pseudo_chance), pseudo_chance) == 0)
            
            obj.SIZE = obj.SIZE + 1;
            new_x = x_generator();
            
            visual_lanes = [];
            for agent_visual = obj.agents
                agent_visual_x = agent_visual.x;
                if agent_visual_x(agent_visual.ss.x_state) < lane_width
                    visual_lanes(end+1) = agent_lanes(agent_visual.id);
                end
            end
            
            counts = hist( ...
                    visual_lanes, ...
                    (1:number_lanes)*lane_gap...
                );
            
            
            [min_count, min_lane] = min(counts(1:end-1));
            if (rand() < 0.1) && (counts(end) < min_count)
                new_y = number_lanes*lane_gap + (rand()-0.5)*15;
            else
                new_y = min_lane*lane_gap + (rand()-0.5)*15;
                
            end
            new_x(obj.ss.y_state) = new_y;
            
            
            %{
            [~, min_lane] = min(counts);
            bypass = 0;            
            if rand() < 0.9 && min_lane == number_lanes
                bypass = 1;
            end
            if ~bypass
                new_x(obj.ss.y_state) = min_lane*lane_gap + (rand()-0.5)*3;
            end
            %}
            
            
            
            % Between lanes 1 and 5
            new_agent_lane = round(new_y / lane_gap)*lane_gap;
            new_agent_lane = max(new_agent_lane, 1*lane_gap);
            new_agent_lane = min(new_agent_lane, number_lanes*lane_gap);
            
            ref = zeros(obj.agentstates, 1); %[0; 0; 0; 0; 0; 0; 0; 0];
            set = getSetPoint(obj.agentstates, obj.ss.y_state, obj.ss.vy_state, new_agent_lane);
            
            new_agent = obj.agent_generator(obj.SIZE, new_x, ref, set);
            obj.agents = [...
                obj.agents, ...
                new_agent
                ];
            
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
            X = X(obj.ss.x_state,:);
            
            % Get the state indeces
            [~, ind] = sort(X, 2);
            
            lane_mod = 1;
            if lane == number_lanes * lane_gap
                lane_mod = 3;
            end
            
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
                    
                    % Relative offsets - we are only doing this in the x 
                    x_diff = abs(prev.x(prev.ss.x_state) - base.x(base.ss.x_state));
                    min_x_delta = max(x_diff, interlane_gap * lane_mod);                    
                    
                    % For the current agent
                    % delta = max(abs(prev.x - base.x), [3; 0; 0; 0; 0; 0; 0; 0]) .* [1; 0; 0; 0; 0; 0; 0; 0];
                    basedelta = zeros(base.numstates, 1);
                    basedelta(base.ss.x_state) = prev.delta(prev.ss.x_state) - min_x_delta;
                    base.delta = basedelta;
                    
                    if (x_diff <= 2*interlane_gap * lane_mod)
                        ADJ(base.id, prev.id) = 1;
                        ADJ(prev.id, base.id) = 1;
                    end
                end
                
                for agentl = in_lane
                    if lane == lane_gap
                        agentl.vx = 1;
                    elseif lane == lane_gap*number_lanes
                        agentl.vx = 11.5;
                    else
                        agentl.vx = NaN;
                    end
                end
                %base.setpoint = [NaN; NaN; NaN; agent_lanes(base.id); 0; 0; NaN; NaN];
                base.setpoint = getSetPoint(base.numstates, base.ss.y_state, base.ss.vy_state, agent_lanes(base.id));
            end
        end
        
        if any(size(ADJ) ~= size(obj.ADJ)) || any(reshape(ADJ ~= obj.ADJ, [], 1))
            obj.ADJ = ADJ;
        end
        
        obj.sim_step;
        
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
    iters
    reassignments
end