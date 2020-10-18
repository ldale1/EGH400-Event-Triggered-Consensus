function PlotEigs(obj)
    % Plot the network eigenvalues
    import ConsensusMAS.Utils.*;
    figure()
    th = 0:pi/50:2*pi;
 
    % Plot the network topology
    figure();
    for i = 1:length(obj.TOPS)
        subplot(1, length(obj.TOPS), i), hold on;
        
        % content
        F = GraphFrobenius(obj.TOPS(i).ADJ);
        t = obj.TOPS(i).t;
        
        % plots
        plot(cos(th), sin(th), 'k--');
        plot(eigs(F), '*');
        title(sprintf('Graph t=%.2f', t))
    end
end