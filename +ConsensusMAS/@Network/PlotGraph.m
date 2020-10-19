function PlotGraph(obj)
    % Plot the network topology
    figure();
    
    % Rows and columns for subplots
    cols = floor(sqrt(length(obj.TOPS)));
    rows = ceil(length(obj.TOPS)/cols);
    
    % Iteratively plot topology graphs
    for i = 1:length(obj.TOPS)
        subplot(cols, rows, i)
        
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
        title(sprintf('Graph t=%.2fs', t))
    end
end