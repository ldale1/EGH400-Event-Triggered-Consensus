function PlotTriggersStates(obj, varargin)
    % Plot the state trajectories
    import ConsensusMAS.Utils.*;
  
    figure(), sgtitle("Agent States and Triggers");
    time = obj.T;
    colors = GetColors(obj.SIZE);
    
    plottype = "plot";
    for k = 1:length(varargin)
        if (strcmp(varargin{k},"plottype"))
            k = k + 1;
            plottype = varargin{k};
        end
    end
    
    % Iteratively plot input states and triggers
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            % states
            states = agent.X(i,:);
            
            if strcmp(plottype, "plot")
                plot(time, states, ...
                    'DisplayName', agent.name, ...
                    'Color', colors(agent.id, :))
            elseif strcmp(plottype, "stairs")
                stairs(time, states, ...
                    'DisplayName', agent.name, ...
                    'Color', colors(agent.id, :))
            else
                error("Plot type not recognised");
            end
            

            % Triggering instances
            triggers = agent.TX(i,:);
            tx_vals = states(logical(triggers));
            tx_time = time(logical(triggers));
            plot(tx_time, tx_vals, '*', ...
                'Markersize', 3, ...
                'HandleVisibility', 'off', ...
                'Color', colors(agent.id, :))
        end
        xlim([time(1) time(end)]);
        legend()
        
        % Labelling
        title(sprintf('State %d', i))
        ylabel('Value');
        xlabel('Time (s)');
    end  
end