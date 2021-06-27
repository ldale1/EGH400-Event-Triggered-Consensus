function PlotErrors(obj)
    % Plot errors, and the threshold
    cols = floor(sqrt(obj.SIZE));
    rows = ceil(obj.SIZE/cols);
    
    % One plot for each state
    time = obj.T;
    for i = 1:obj.agentstates
        figure();
        sgtitle(sprintf("Agent Errors", i));
        for agent = obj.agents
            subplot(cols, rows, agent.id), hold on;

            error = sqrt(sum(agent.ERROR.^2, 1));
            threshold = agent.ERROR_THRESHOLD(i,:);

            stairs(time, threshold, 'DisplayName', 'threshold')
            stairs(time, error, 'DisplayName', 'error')
            
            legend()
            
            % Limit time axis
            xlim([time(1) time(end)])
            
            % Label axes
            xlabel('Time (s)')
            ylabel(agent.name + ' Error');
            grid on;
        end
    end
end