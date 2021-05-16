function PlotErrorsNorm(obj, varargin)
    % Plot the inputs
    plottype = "none";
    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "subplots"))
            k = k + 1;
            plottype = varargin{k};
        end
    end
    
    % Plot errors, and the threshold
    plots = obj.agentstates;
    cols = floor(sqrt(plots));
    rows = ceil(plots/cols);
    
    % One plot for each state
    time = obj.T;
    
    
    
    Xs = zeros(obj.SIZE, length(obj.T));
    for i = 1:obj.agentstates
        
        for ii = 1:obj.SIZE
            Xs(ii,:) = obj.agents(ii).X(i,:);
        end
        standard = std(Xs, 1);
        
        if strcmp(plottype, "none")
            figure(998), hold on, legend()
            title(sprintf("Agent Error Norms", i));
        elseif strcmp(plottype, "states")
            figure(999), subplot(rows, cols, i), hold on, legend(); 
            sgtitle(sprintf("Agent Error Norm State", i));
        end
        
        plot(time, standard, "DisplayName", sprintf("State %d", i));
        
    end
    
    
    
    
end

