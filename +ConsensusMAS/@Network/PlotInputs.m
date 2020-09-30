function PlotInputs(obj, varargin)
    % Plot the inputs
    plottype = "plot";
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
    end

    figure();
    hold on;
    for agent = network.agents
        if strcmp(plottype, "plot")
            plot(obj.T(2:end), agent.U, 'DisplayName', agent.name)
        elseif strcmp(plottype, "stairs")
            stairs(obj.T(2:end), agent.U, 'DisplayName', agent.name)
        else
            error("Plot type not recognised");
        end

    end
    xlim([obj.T(1) obj.T(end)]);
    title('Inputs')
    legend()
end