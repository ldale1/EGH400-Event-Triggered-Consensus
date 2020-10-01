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
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            if strcmp(plottype, "plot")
                plot(agent.U(i,:), 'DisplayName', agent.name)
            elseif strcmp(plottype, "stairs")
                stairs(agent.U(i,:), 'DisplayName', agent.name)
            else
                error("Plot type not recognised");
            end
        end
        %xlim([obj.T(1) obj.T(end)]);
        title('Agents')
        legend()
    end  
end