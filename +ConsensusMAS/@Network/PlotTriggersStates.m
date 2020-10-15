function PlotTriggersStates(obj)
    % Plot the state trajectories
  
    figure();
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            time = obj.T;
            states = agent.X(i,:);
            plot(obj.T, states, 'DisplayName', agent.name)


            triggers = agent.TX(i,:);
            tx_vals = states(logical(triggers));
            tx_time = time(logical(triggers));

            plot(tx_time, tx_vals, '*', 'HandleVisibility', 'off')
        end
        xlim([obj.T(1) obj.T(end)]);
        title('Agents')
        legend()
    end  
end