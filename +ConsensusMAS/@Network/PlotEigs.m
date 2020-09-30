function PlotEigs(obj)
    % Plot the network eigenvalues
    figure()
    hold on;
    th = 0:pi/50:2*pi;
    plot(cos(th), sin(th), 'k--');
    plot(obj.eigenvalues, '*');
end