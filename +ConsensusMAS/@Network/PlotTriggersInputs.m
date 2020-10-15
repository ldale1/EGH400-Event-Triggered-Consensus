function PlotTriggersInputs(obj)
    % Plot the state trajectories
  
    
    figure();
    t = obj.T;
     
    for i = 1:obj.agentinputs
        subplot(obj.agentinputs, 1, i), hold on;
        
        for agent = obj.agents
            inputs = agent.U(i,:);
            stairs(t, inputs, 'DisplayName', agent.name)

            triggers = agent.TX(i,:);
            tx_vals = inputs(logical(triggers));
            tx_time = t(logical(triggers));

            plot(tx_time, tx_vals, '*', 'HandleVisibility', 'off')
        end


        xlim([t(1) t(end)]);
        title('Agents')
        legend()
    end  
end