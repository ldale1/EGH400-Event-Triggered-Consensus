function Animate(obj, title)
    % Network simulation animation

    % This is two dimensional, assert as much
    assert(obj.agentstates == 2, "Wrong number of states");
    
    % Imports
    import ConsensusMAS.Utils.*;

    %{
    % Format the data
    % inputs: agent x rows, steps x columns
    X1 = zeros(obj.SIZE, length(obj.T));
    X2 = zeros(obj.SIZE, length(obj.T));
    TX = zeros(obj.SIZE, length(obj.T));
    
    for agent = obj.agents
        X1(agent.id,:) = agent.X(1,:);
        X2(agent.id,:) = agent.X(2,:);
        TX(agent.id,:) = any(agent.TX);
    end
    
    % Axis minmax
    xmin = min(reshape(X1, [], 1)); xmax = max(reshape(X1, [], 1));
    ymin = min(reshape(X2, [], 1)); ymax = max(reshape(X2, [], 1));
    
    % Scale out
    scale = 0.1;
    xmin = xmin - (xmax - xmin) * scale; xmax = xmax + (xmax - xmin) * scale;
    ymin = ymin - (ymax - ymin) * scale; ymax = ymax + (ymax - ymin) * scale;
    %}
     

    % Setup
    mov(1:length(obj.T)) = struct('cdata',[],'colormap',[]);
    scrsz = get(0,'ScreenSize');
    figmovie = figure('Name','Movie: Consensus', 'Position',[0, 0, scrsz(4)*0.75, scrsz(4)*0.75]);
    fs = 1/(obj.T(2) - obj.T(1));
    
    % Colors
    colors = GetColors(obj.SIZE);
       
    for k = 1:length(obj.T)
        % Set the labels for each frame of the animation
        figmovie; clf, hold on;
        xlabel('x [m]', 'FontSize', 18)
        ylabel('y [m]', 'FontSize', 18)
        
        
        % Draw the states
        %history = max(k - ceil(length(time)/5), 1);
        history = 1;%max(k - 100, 1);
        for agent = obj.agents
            color = colors(agent.id,:);
            
            % States 
            x_vals = agent.X(1, history:k);
            y_vals = agent.X(2, history:k);
            plot(x_vals, y_vals, 'color', colors(agent.id,:));
            
            % Transmissions
            txs = logical(any(agent.TX(:,history:k)));
            plot(x_vals(txs), y_vals(txs), '*', ...
                'color', color, 'Markersize', 3);
            
            % Current pos agent number
            text(x_vals(end), y_vals(end), sprintf("%d", agent.id), ...
                'HorizontalAlignment', 'center')
        end
        
        ax = gca;
        text(ax.XLim(end), ax.YLim(end), sprintf('Time %0.2f sec', obj.T(k)), ...
            'FontSize',18, ...
            'VerticalAlignment','top', ...
            'HorizontalAlignment', 'right')

        % Record frame data
        mov(k) = getframe(gcf);
    end

    % Make video
    vidObj = VideoWriter(sprintf('%s.avi', title));
    vidObj.FrameRate = fs;
    open(vidObj);
    writeVideo(vidObj, mov);
    close(vidObj)
end
