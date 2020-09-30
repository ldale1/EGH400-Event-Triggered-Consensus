function PlotTriggers(obj)
    % Plot the network eigenvalues
    figure(), hold on;
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            tx_time = obj.T(logical(obj.TX(i,:,agent.id)));
            plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
            text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
        end
    end
end   