function PlotStates(obj,varargin)
    % Plot the state trajectories
    plottype = "plot";
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
    end
    
    figure(), sgtitle("Agent States");
    time = obj.T;
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(time, agent.X(i,:), 'DisplayName', agent.name)
            elseif strcmp(plottype, "stairs")
                stairs(time,  agent.X(i,:), 'DisplayName', agent.name)
            else
                error("Plot type not recognised");
            end
        end
        xlim([time(1) time(end)]);
        legend()
        
        % Labelling
        title(sprintf('State %d', i))
        ylabel('Value');
        xlabel('Time (s)');
    end  
end