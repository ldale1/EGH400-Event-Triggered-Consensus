function Plot3(obj)
    
    assert(obj.agentstates == 2, "Wrong number of states");
    
    figure(), hold on, grid on;
    for agent = obj.agents
        plot3(obj.X(1,:,agent.id)', obj.X(2,:,agent.id)', obj.T')
    end
    xlabel('x_1')
    ylabel('x_2')
    zlabel('t')
    view(-70,30)

    %{
    % Plot the trigger times
    figure(), hold on;
    for i = 1:obj.agentstates
        subplot(obj.agentstates, 1, i), hold on;
        for agent = obj.agents
            % Get the network triggering times
            tx_time = obj.T(logical(obj.TX(i,:,agent.id)));
            plot(tx_time, agent.id*ones(1, length(tx_time)), '*')
            if length(tx_time) >= 1
                text(tx_time(end), agent.id, sprintf("(%d)", length(tx_time)))
            end
        end
        %xlim([0 0.8])
        ylim([0 agent.id + 1])
    end
    %}
end   