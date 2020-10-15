function MovieMaker(time, x, y, tx)

    % Setup
    mov(1:length(time)) = struct('cdata',[],'colormap',[]);
    scrsz = get(0,'ScreenSize');
    figmovie=figure('Name','Movie: Consensus', 'Position',[0, 0, scrsz(4)*0.75, scrsz(4)*0.75]);
        
    % Axis minmax
    xmin = min(reshape(x, [], 1)); xmax = max(reshape(x, [], 1));
    ymin = min(reshape(y, [], 1)); ymax = max(reshape(y, [], 1));
    
    % Scale out
    scale = 0.1;
    xmin = xmin - (xmax - xmin) * scale; xmax = xmax + (xmax - xmin) * scale;
    ymin = ymin - (ymax - ymin) * scale; ymax = ymax + (ymax - ymin) * scale;

    
    SIZE = size(x, 1);
    colors = get(gca,'colororder');
    ncolors = size(colors, 1);
    if (SIZE > ncolors)
        for i = ncolors+1:SIZE
            colors(i,:) = [rand, rand, rand];
        end
    end
       
    for k=1:length(time)
        % Set the labels for each frame of the animation
        figmovie; clf; hold on;
        xlabel('x [m]', 'FontSize', 18)
        ylabel('y [m]', 'FontSize', 18)
        text(xmax, ymax, sprintf('Time %0.2f sec', time(k)), ...
            'FontSize',18, ...
            'VerticalAlignment','top', ...
            'HorizontalAlignment', 'right')
        

        
        % Draw the states
        %history = max(k - ceil(length(time)/5), 1);
        history = 1;%max(k - 100, 1);
        for i = 1:SIZE
            % States 
            x_vals = x(i, history:k);
            y_vals = y(i, history:k);
            plot(x_vals, y_vals, 'color', colors(i,:));
            
            % Transmissions
            txs = logical(tx(i, history:k));
            plot(x_vals(txs), y_vals(txs), '*', 'color', colors(i,:), 'Markersize', 3);
            
            % Current pos
            text(x(i, k), y(i, k), sprintf("%d", i), 'HorizontalAlignment', 'center')
        end
        
        xlim([xmin, xmax])
        ylim([ymin, ymax])

        % Record frame data
        mov(k) = getframe(gcf);
    end

    vidObj = VideoWriter('ConsensusAnimation.avi');
    vidObj.FrameRate = 1/(time(2) - time(1));
    open(vidObj);
    writeVideo(vidObj, mov);
    close(vidObj)
end
