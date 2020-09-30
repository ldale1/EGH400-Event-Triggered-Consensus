function MovieMaker(time, x, y, x_tx, y_tx)
    mov(1:length(time)) = struct('cdata',[],'colormap',[]);

    % Auxiliar variables

    scrsz = get(0,'ScreenSize');
    figmovie=figure('Name','Movie: Consensus', 'Position',[0, 0, scrsz(4)*0.75, scrsz(4)*0.75]);
        
    scale = 1.1;
    xmin = min(reshape(x, [], 1)) * scale;
    xmax = max(reshape(x, [], 1)) * scale;
    ymin = min(reshape(y, [], 1)) * scale;
    ymax = max(reshape(y, [], 1)) * scale;
    
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
        figmovie; clf;
        xlabel('x [m]', 'FontSize', 18)
        ylabel('y [m]', 'FontSize', 18)
        text(xmax, ymax, sprintf('Time %0.2f sec', time(k)), 'FontSize',18,'VerticalAlignment','top', 'HorizontalAlignment', 'right')
        hold on;

        % Draw the states
        for i = 1:SIZE
            % States 
            x_vals = x(i, 1:k);
            y_vals = y(i, 1:k);
            plot(x_vals, y_vals, 'color', colors(i,:));
            
            % Transmissions
            x_txs = x_tx(i, 1:k);
            y_txs = x_tx(i, 1:k);
            txs = logical(x_txs + y_txs);
            plot(x_vals(txs), y_vals(txs), 'o', 'color', colors(i,:));
            
            % Current pos
            text(x(i, k), y(i, k), sprintf("%d", i), 'HorizontalAlignment', 'center')
        end
        
        xlim([xmin, xmax])
        ylim([ymin, ymax])

        % Record frame data
        mov(k) = getframe(gcf);
    end

    vidObj = VideoWriter('ConsensusAnimation.avi');
    vidObj.FrameRate = 100;
    open(vidObj);
    writeVideo(vidObj, mov);
    close(vidObj)
end
