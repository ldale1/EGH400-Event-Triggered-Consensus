function PlotTriggers(obj)
    % Plot the trigger times
    figure(), hold on;
    t = obj.T;
    for i = 1:obj.agentstates
        subplot(obj.agentstates+1, 1, i), hold on;
        for agent = obj.agents
            % Get the network triggering times
            tx_time = obj.T(logical(obj.TX(i,:,agent.id)));
            plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
            if length(tx_time) >= 1
                text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
            end
        end
        xlim([t(1) t(end)])
        ylim([0 agent.id + 1])
    end
    
    
       
    subplot(obj.agentstates+1, 1, obj.agentstates+1), hold on;
    for agent = obj.agents
        % Get the network triggering times
        tx_time = obj.T(logical(any(obj.TX(:,:,agent.id))));
        plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
        if length(tx_time) >= 1
            text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
        end
    end
    xlim([t(1) t(end)])
    ylim([0 agent.id + 1])
    
end   