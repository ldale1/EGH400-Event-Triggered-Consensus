function PlotInputs(obj, varargin)
    % Plot the inputs
    plottype = "plot";
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
    end

    figure(), sgtitle("Control Inputs");
    time = obj.T;
    for i = 1:obj.agentinputs
        subplot(obj.agentinputs, 1, i), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(time, agent.U(i,:), 'DisplayName', agent.name)
            elseif strcmp(plottype, "stairs")
                stairs(time, agent.U(i,:), 'DisplayName', agent.name)
            else
                error("Plot type not recognised");
            end
        end
        
        % Formatting
        legend()
        xlim([time(1) time(end)]);
        
        % Labelling
        if (obj.agentinputs > 1)
            title(sprintf('Input %d', i))
        end
        ylabel('Value');
        xlabel('Time (s)');
        grid on 
    end  
end