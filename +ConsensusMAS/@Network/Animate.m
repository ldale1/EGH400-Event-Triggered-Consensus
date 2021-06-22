function Animate(obj, varargin)
    % Network simulation animation    
    
    % Imports
    import ConsensusMAS.Utils.*;
    
    % Sample frequency
    time = obj.T;
    fs = 1/(time(2) - time(1));
    
    % Parse Args
    fixedaxes = NaN;
    historyticks = time(end)*fs;
    title_mov = "consensus_animation";
    state1 = 1;
    state2 = 2;
    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "title"))
            title_mov = varargin{k + 1};
        end
        
        if (strcmp(varargin{k}, "history"))
            historyticks = floor(varargin{k + 1}*fs);
        end
        
        if (strcmp(varargin{k}, "states"))
            states = varargin{k + 1};
            state1 = states(1);
            state2 = states(2);
        end
        
        if (strcmp(varargin{k}, "fixedaxes"))
            fixedaxes = varargin{k + 1};
        end
    end
    
    
    % This is two dimensional, assert as much
    assert(obj.agentstates >= max(state1, state2), "Wrong number of states");
 

    % Setup
    mov(1:length(time)) = struct('cdata',[],'colormap',[]);
    scrsz = get(0,'ScreenSize');
    figmovie = figure(...
        'Name', 'Movie: Consensus', ...
        'Position',[0, 0, scrsz(4)*0.75, scrsz(4)*0.75]);
    
    
    % Colors
    colors = GetColors(obj.SIZE);
       
    for k = 1:length(time)
        % Set the labels for each frame of the animation
        figmovie; clf, hold on;
        xlabel('x [m]', 'FontSize', 18)
        ylabel('y [m]', 'FontSize', 18)

        % Draw the states
        %history = max(k - ceil(length(time)/5), 1);
        startindex = max(k - historyticks, 1);
        for agent = obj.agents
            color = colors(agent.id,:);
            
            % States 
            x_vals = agent.X(state1, startindex:k);
            y_vals = agent.X(state2, startindex:k);
            plot(x_vals, y_vals, 'color', colors(agent.id,:));
            
            % Transmissions
            txs = logical(any(agent.TX(:,startindex:k)));
            plot(x_vals(txs), y_vals(txs), '*', ...
                'color', color, 'Markersize', 3);
            
            % Current pos agent number
            if ~isnan(fixedaxes)
                if ~(x_vals(end) > fixedaxes(2) || ...
                     x_vals(end) < fixedaxes(1) || ...
                     y_vals(end) > fixedaxes(4) || ...
                     y_vals(end) < fixedaxes(3))
                    text(x_vals(end), y_vals(end), sprintf("%d", agent.id), ...
                            'HorizontalAlignment', 'center')
                end
            else
                text(x_vals(end), y_vals(end), sprintf("%d", agent.id), ...
                'HorizontalAlignment', 'center')
            end
            
        end
        
        
        if ~isnan(fixedaxes)
            axis(fixedaxes)
            
            % background
            I = imread('cityview.jpg'); 
            h = image(fixedaxes(1:2), fixedaxes(3:4), I); 
            h.AlphaData = 0.1;
            uistack(h,'bottom')
        end
        
        ax = gca;
        text(ax.XLim(end), ax.YLim(end), sprintf('Time %0.2f sec', time(k)), ...
            'FontSize',18, ...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment', 'right')
        
        grid on;
        % Record frame data
        mov(k) = getframe(gcf);
    end

    % Make video
    vidObj = VideoWriter(sprintf('%s.avi', title_mov));
    vidObj.FrameRate = 3*fs;
    open(vidObj);
    writeVideo(vidObj, mov);
    close(vidObj)
end