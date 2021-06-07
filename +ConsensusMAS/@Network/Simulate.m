function Simulate(obj, type, varargin)
    % Run the network simulation
    function exit_func = DynamicFunc(t, varargin)
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
        exit_func = @(t, c) ...
            (((round(t - mintime, 6) >= 0) && c) ||  t > maxtime);
    end

    function exit_func = FixedFunc(t, varargin)
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
    

    fprintf("Simulate begin...\n")
    
    % Simulate
    while (true)
        obj.sim_step;
        %obj.assign_formation();
        
        % Check the exit conditions
        if exit_func(obj.t, obj.consensus)
            break;
        end
    end
end