function PlotGraph(obj)
    % Plot the network topology
    figure();
    for i = 1:length(obj.TOPS)
        subplot(1, length(obj.TOPS), i)
        
        % content
        ADJ = obj.TOPS(i).ADJ;
        t = obj.TOPS(i).t;
        
        % plots
        directed = any(reshape(tril(ADJ) ~= tril(ADJ'), [], 1));
        if ~directed
            g = graph(ADJ');
        else
            g = digraph(ADJ');
        end
        plot(g, 'EdgeLabel', g.Edges.Weight)
        title(sprintf('Graph t=%.2f', t))
    end
end