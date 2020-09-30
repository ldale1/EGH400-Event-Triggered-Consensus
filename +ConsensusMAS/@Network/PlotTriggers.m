function PlotTriggers(obj)
    % Plot the network eigenvalues
    figure()
    hold on;
    for agent = obj.agents
        triggers = obj.TRIGGERS([obj.TRIGGERS.id] == agent.id);
        triggers_time = [triggers.t];
        plot(triggers_time, agent.id*ones(1, length(triggers)), '*')
        text(triggers_time(end), agent.id, sprintf("(%d)", length(triggers)))
    end
end   