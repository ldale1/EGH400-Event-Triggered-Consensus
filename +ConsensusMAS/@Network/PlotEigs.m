function PlotEigs(obj)
    % Plot the network eigenvalues
    % This is useful for algebraic connectivity, max eigenvalue
    import ConsensusMAS.Utils.*;
    figure()
    
    % Rows and columns for subplot
    cols = floor(sqrt(length(obj.TOPS)));
    rows = ceil(length(obj.TOPS)/cols);
    
    % Plot the network topology
    figure();
    for i = 1:length(obj.TOPS)
        subplot(cols, rows, i), hold on;
        
        % Content
        F = GraphFrobenius(obj.TOPS(i).ADJ);
        t = obj.TOPS(i).t;
        
        
        % Plots
        eigvals = eigs(F);
        plot(real(eigvals), imag(eigvals), '*');
        title(sprintf('Graph t=%.2f', t))
    end
end