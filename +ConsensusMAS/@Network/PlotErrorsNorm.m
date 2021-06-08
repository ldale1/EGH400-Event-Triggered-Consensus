function PlotErrorsNorm(obj, varargin)
    % Plot the inputs
    
    
    % One plot for each state
    time = obj.T;
    
    
    Xs = zeros(obj.SIZE, length(obj.T));
    for i = 1:obj.agentstates
        
        for ii = 1:obj.SIZE
            Xs(ii,:) = obj.agents(ii).X(i,:);
        end
        
        % 
        standard = std(Xs, 1);
        
        % Sum errors sq, average --> sum for agents // experiment
        
        if strcmp(plottype, "none")
            figure(998), hold on, legend()
            title(sprintf("Agent Error Norms", i));
        elseif strcmp(plottype, "states")
            figure(999), subplot(rows, cols, i), hold on, legend(); 
            sgtitle(sprintf("Agent Error Norm State", i));
        end
        
        plot(time, standard, "DisplayName", sprintf("State %d", i));
        
    end

    
        % 
    figure()
    actual = sum(Xs);
    plot(time, actual/max(actual), "DisplayName", sprintf("State %d", i));
end

