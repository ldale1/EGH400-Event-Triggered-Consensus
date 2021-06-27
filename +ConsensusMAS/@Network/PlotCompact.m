function PlotStates(obj,varargin)
    % Plot the state trajectories
    plottype = "plot";
    w_disturbance = 0;
    
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
        if (strcmp(varargin{k}, "disturbance"))
            k = k + 1;
            w_disturbance = varargin{k};
        end
    end
    
    figure();
    import ConsensusMAS.ControllersEnum; 
    switch (obj.controller)
        case ControllersEnum.Smc
            sgtitle("Sliding Mode");

        otherwise
            sgtitle("State Feedback");
            
    end
    
     
    time = obj.T;
    for i = 1:obj.agentstates
        subplot(2, 1, 1), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(time, agent.X(i,:), 'DisplayName', sprintf("x_%d", i))
                if any(agent.D(i,:))
                    plot(time, agent.D(i,:), '--', 'DisplayName', sprintf("x_%d disturbance", i))
                end
            elseif strcmp(plottype, "stairs")
                stairs(time,  agent.X(i,:), 'DisplayName', agent.name)
                if any(agent.D(i,:), 'DisplayName', sprintf("x_%d", i))
                    stairs(time, agent.D(i,:), '--', 'DisplayName', sprintf("x_%d disturbance", i))
                end
            else
                error("Plot type not recognised");
            end
        end
        xlim([time(1) time(end)]);
        
        if (length(obj.agents) < 20)
            legend()
        end
        
        grid on;
        
        % Labelling
        title("States")
        ylabel('Value');
        xlabel('Time (s)');
    end  
    
    for i = 1:obj.agentinputs
        subplot(2, 1, 2), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(time, agent.U(i,:), 'DisplayName', sprintf("%s", agent.name))
            elseif strcmp(plottype, "stairs")
                stairs(time,  agent.X(i,:), 'DisplayName', sprintf("%s", agent.name))
            else
                error("Plot type not recognised");
            end
        end
        xlim([time(1) time(end)]);
        
        if (length(obj.agents) < 20)
            %legend()
        end
        
        grid on;
        
        % Labelling
        title("Inputs")
        ylabel('Value');
        xlabel('Time (s)');
    end  
end