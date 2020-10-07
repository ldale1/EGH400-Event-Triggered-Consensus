function PlotGraph(obj)
    % Plot the network topology
    figure();
    
    directed = any(reshape(tril(obj.A) ~= tril(obj.A'), [], 1));
    if ~directed
        g = graph(obj.ADJ');
    else
        g = digraph(obj.ADJ');
    end
    plot(g,'EdgeLabel',g.Edges.Weight)
    title('Graph')
end