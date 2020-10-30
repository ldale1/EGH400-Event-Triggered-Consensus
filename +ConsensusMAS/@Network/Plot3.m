function Plot3(obj, varargin)
    % Three dimensional plot to see 2x states over time    
    import ConsensusMAS.Utils.*;
    
    state1 = 1;
    state2 = 2;
    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "states"))
            states = varargin{k + 1};
            state1 = states(1);
            state2 = states(2);
        end
    end
    
    assert(obj.agentstates >= max(state1, state2), "Wrong number of states");
    
    time = obj.T;
    colors = GetColors(obj.SIZE);
    
    figure(), hold on, grid on;
    for agent = obj.agents
        % Agent transmissions, states
        TX = any(agent.TX);
        x1 = agent.X(state1, :);
        x2 = agent.X(state2, :);
        
        % Plot both
        plot3(x1(TX), x2(TX), time(TX), '*', 'Markersize', 3, 'Color', colors(agent.id, :));
        plot3(x1, x2, time, 'Color', colors(agent.id, :));
    end
    
    % Labelling
    xlabel('x_1')
    ylabel('x_2')
    zlabel('Time (s)')
    view(-70,25)
end   