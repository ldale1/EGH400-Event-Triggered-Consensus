function PlotGraphStates(obj, varargin)
    % Plot graph and states in subplot
    plottype = "plot";
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
    end

    figure();
    subplot(121);
    plot(digraph(obj.F'));
    title('Graph')

    subplot(122);
    hold on;
    for agent = obj.agents
        if strcmp(plottype, "plot")
            plot(obj.T, agent.X, 'DisplayName', agent.name)
        elseif strcmp(plottype, "stairs")
            stairs(obj.T, agent.X, 'DisplayName', agent.name)
        else
            error("Plot type not recognised");
        end
    end
    xlim([obj.T(1) obj.T(end)]);
    title('Agents')
    legend()
end