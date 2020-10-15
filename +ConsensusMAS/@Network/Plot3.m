function Plot3(obj)
    
    assert(obj.agentstates == 2, "Wrong number of states");
    
    figure(), hold on, grid on;
    for agent = obj.agents
        t = obj.T;
        TX = any(agent.TX);
        x1 = agent.X(1, :);
        x2 = agent.X(2, :);
        
        plot3(x1(TX), x2(TX), t(TX), '*', 'Markersize', 3);
        plot3(x1, x2, t);
    end
    
    xlabel('x_1')
    ylabel('x_2')
    zlabel('t')
    view(-70,25)
end   