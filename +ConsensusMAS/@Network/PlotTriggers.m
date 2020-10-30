function PlotTriggers(obj)
    % Plot the trigger times
    figure(), hold on;
    time = obj.T;

    
    
    for agent = obj.agents
        % Get the network triggering times
        tx = agent.TX;
        tx_time = time(logical(any(tx)));
            
        plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
        if length(tx_time) >= 1
            text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
        end
    end
    xlim([time(1) time(end)])
    ylim([0 obj.SIZE + 1])
    
    sgtitle('Agent Triggering Instants')
    ylabel('Agent ID')
    xlabel('Time (s)');
end   

%{
function PlotTriggers(obj)
    % Plot the trigger times
    figure(), hold on;
    time = obj.T;
    for i = 1:obj.agentstates
        subplot(obj.agentstates+1, 1, i), hold on;
        for agent = obj.agents
            % Get the network triggering times
            tx = agent.TX(i,:);
            tx_time = time(logical(tx));
            
            
            plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
            if length(tx_time) >= 1
                text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
            end
        end
        xlim([time(1) time(end)])
        ylim([0 obj.SIZE + 1])
    end
    
    
       
    subplot(obj.agentstates+1, 1, obj.agentstates+1), hold on;
    for agent = obj.agents
        % Get the network triggering times
        tx = agent.TX;
        tx_time = time(logical(any(tx)));
            
        plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
        if length(tx_time) >= 1
            text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
        end
    end
    xlim([time(1) time(end)])
    ylim([0 obj.SIZE + 1])
    
end   

%}