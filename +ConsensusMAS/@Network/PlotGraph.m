function PlotGraph(obj)
    % Plot the network topology
    figure();
    plot(digraph(obj.F'));
    title('Graph')
end