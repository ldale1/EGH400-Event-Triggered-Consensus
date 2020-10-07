function PlotTriggersInputs(obj)
    % Plot the state trajectories
  
    
    figure();
    time = obj.T;
     
    for i = 1:obj.agentinputs
        subplot(obj.agentinputs, 1, i), hold on;
        
        triggers_all = any(squeeze(obj.TX(i,:,:))');
        triggers_any = any(squeeze(any(obj.TX(:,:,:)))');
        for t = time(logical(triggers_all))
            %plot([t, t], [-1e3, 1e3], '--', 'Color', [0.2 0.2 0.2, 0.3], 'HandleVisibility', 'off');
        end      
        
        for t = time(logical(triggers_any - triggers_all))
            %plot([t, t], [-1e3, 1e3], '--', 'Color', [0.05 0.05 0.05, 0.1], 'HandleVisibility', 'off');
        end 
        
        for agent = obj.agents
            inputs = obj.U(i,:,agent.id);
            stairs(obj.T, inputs, 'DisplayName', agent.name)

            triggers = obj.TX(i,:,agent.id);
            tx_vals = inputs(logical(triggers));
            tx_time = time(logical(triggers));

            plot(tx_time, tx_vals, '*', 'HandleVisibility', 'off')
        end
        
        ymin = min(reshape(squeeze(obj.U(i,:,:)), [], 1))*1.05;
        ymax = max(reshape(squeeze(obj.U(i,:,:)), [], 1))*1.05;

        ylim([ymin, ymax])
        xlim([obj.T(1) obj.T(end)]);
        title('Agents')
        legend()
    end  
end