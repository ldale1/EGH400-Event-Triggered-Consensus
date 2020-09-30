function PlotTriggersStates(obj)
    figure();
    hold on;
    for agent = obj.agents
        plot(obj.T, agent.X, 'DisplayName', agent.name)

        % When is it triggering
        triggers = obj.TRIGGERS([obj.TRIGGERS.id] == agent.id);
        triggers_time = [triggers.t];

        % These indeces in time array
        [a, b] = ismember(triggers_time, obj.T);

        % Plot
        plot(triggers_time, agent.X(b), '*', 'HandleVisibility', 'off')
    end
    xlim([obj.T(1) obj.T(end)]);
    title('Agents')
    legend()
end