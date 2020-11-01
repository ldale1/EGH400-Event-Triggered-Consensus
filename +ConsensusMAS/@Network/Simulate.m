function Simulate(obj, type, varargin)
    % Run the network simulation
   
    
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
    
    

    % Begin
    % Agents are initialised with
    % x = x0, u = 0, xhat = 0            
    %{
    for agent = obj.agents
        agent.sample();
    end

    for agent = obj.agents
        agent.broadcast();
    end

    for agent = obj.agents
        agent.setinput();
    end

    % Have agents save their data
    for agent = obj.agents
        agent.save();
    end

    % Step accordingly
    for agent = obj.agents
        agent.step();
    end 
    %}


    
    % Simulate
    while (true) 
        
        % Check for an incoming transmission
        for agent = obj.agents
            agent.check_receive()
        end 
        
        % Broadcast agents if needed
        for agent = obj.agents
            agent.check_trigger();
        end

        % Have agents save their data
        for agent = obj.agents
            agent.save();
        end
        
        % Step accordingly
        for agent = obj.agents
            agent.step();
        end 

        obj.t = obj.t + obj.ts;
        
        %{
        if obj.t > 150 && obj.t < 160
            fprintf("STEP:\n")
            disp(obj.t)
            disp(squeeze([obj.agents.tx]))
            disp(squeeze([obj.agents.xhat]))
            disp(squeeze([obj.agents.u]))
            fprintf("\n")
        end
        %}

        % Check the exit conditions
        if exit_func(obj.t, obj.consensus)
            break;
        end
    end
end