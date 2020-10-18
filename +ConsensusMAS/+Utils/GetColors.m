function colors = GetColors(ncolors)
    % Get colors
    
    % Associated with current axis
    colors = get(gca,'colororder');
    
    % How many was it
    xcolors = size(colors, 1);
    
    if (ncolors > xcolors)
        for i = xcolors+1 : ncolors
            colors(i,:) = [rand, rand, rand];
        end
    end
end

