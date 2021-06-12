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
    
    figure(), sgtitle("Agent States");
    time = obj.T;
    for i = 1:obj.agentstates
        
        ymin = Inf;
        ymax = -Inf;
        
        
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(time, agent.X(i,:), 'DisplayName', sprintf("%s", agent.name))
                
                if any(agent.D(i,:)) && w_disturbance
                    plot(time, agent.D(i,:), '--', 'DisplayName', sprintf("%s disturbance", agent.name))
                end
            elseif strcmp(plottype, "stairs")
                stairs(time,  agent.X(i,:), 'DisplayName', sprintf("%s", agent.name))
                
                if any(agent.D(i,:)) && w_disturbance
                    stairs(time, agent.D(i,:), '--', 'DisplayName', sprintf("%s disturbance", agent.name))
                end
            else
                error("Plot type not recognised");
            end
            
            states = agent.X(i,:);
            ymin = min(ymin, min(states));
            ymax = max(ymax, max(states));
        end
        ylim([ymin ymax]);
        xlim([time(1) time(end)]);
        
        if (length(obj.agents) < 20)
            legend()
        end
        
        
        
        grid on;
        
        % Labelling
        title(sprintf('State %d', i))
        ylabel('Value');
        xlabel('Time (s)');
    end  
end