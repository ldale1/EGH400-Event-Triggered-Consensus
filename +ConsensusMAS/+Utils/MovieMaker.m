function MovieMaker(time, x, y)


    mov(1:length(time)) = struct('cdata',[],'colormap',[]);

    % Auxiliar variables

    scrsz = get(0,'ScreenSize');
    figmovie=figure('Name','Movie: Consensus',...
                        'Position',[0, 0, scrsz(4)*0.75, scrsz(4)*0.75]);

    xmin = min(reshape(x, [], 1));
    xmax = max(reshape(x, [], 1));
    ymin = min(reshape(y, [], 1));
    ymax = max(reshape(y, [], 1));
                    
    for k=1:length(time)

        % Set the labels for each frame of the animation
        figmovie; clf
        axes('NextPlot','replacechildren','tag','plot_axes')
        xlabel('x [m]', 'FontSize', 18)
        ylabel('y [m]', 'FontSize', 18)
        %text(xp1plane/2+xp2plane/2,-1.4*l, sprintf('Time %0.1f sec', time(k)), 'FontSize',18)
        hold on;

        % Draw the suporting plane base for the cart
        for i = 1:size(x, 1)
            text(x(i, k), y(i, k), sprintf("%d", i))
        end
        
        xlim([xmin, xmax])
        ylim([ymin, ymax])

        % Record frame data
        mov(k) = getframe(gcf);
    end

    vidObj = VideoWriter('ConsensusAnimation.avi');
    vidObj.FrameRate = 240;
    open(vidObj);
    writeVideo(vidObj, mov);
    close(vidObj)
end
