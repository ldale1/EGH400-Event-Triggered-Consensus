function PlotTriggersInputs(obj)
    % Plot the state trajectories
    import ConsensusMAS.Utils.*;
    
    figure();
    time = obj.T;
    colors = GetColors(obj.SIZE);
    
    % Iteratively plot input values and triggers
    for i = 1:obj.agentinputs
        subplot(obj.agentinputs, 1, i), hold on;
        
        for agent = obj.agents
            % Inputs
            inputs = agent.U(i,:);
            stairs(time, inputs, ...
                'DisplayName', agent.name,...
                'Color', colors(agent.id, :))

            % Triggering instances
            triggers = logical(agent.TX(i,:));
            tx_time = time(triggers);
            tx_vals = inputs(triggers);
            plot(tx_time, tx_vals, '*', ...
                'Markersize', 3, ...
                'HandleVisibility', 'off', ...
                'Color', colors(agent.id, :))
        end

        % Format plot
        xlim([time(1) time(end)]);
        title('Agents')
        legend()
    end  
end