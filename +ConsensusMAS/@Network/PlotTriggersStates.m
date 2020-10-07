function PlotTriggersStates(obj)
    % Plot the state trajectories
  
    figure();
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            time = obj.T;
            states = obj.X(i,:,agent.id);
            plot(obj.T, states, 'DisplayName', agent.name)


            triggers = obj.TX(i,:,agent.id);
            tx_vals = states(logical(triggers));
            tx_time = time(logical(triggers));

            plot(tx_time, tx_vals, '*', 'HandleVisibility', 'off')
            if length(tx_time) >= 1
                text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
            end
        end
        xlim([obj.T(1) obj.T(end)]);
        title('Agents')
        legend()
    end  
end