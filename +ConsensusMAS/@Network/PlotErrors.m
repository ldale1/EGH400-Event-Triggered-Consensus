function PlotErrors(obj)
    % 
    cols = floor(sqrt(obj.SIZE));
    rows = ceil(obj.SIZE/cols);
    
    for i = 1:obj.agentstates
        figure();
        for agent = obj.agents
            subplot(cols, rows, agent.id), hold on;

            err = agent.ERROR(i,:);
            thresh = agent.ERROR_THRESHOLD(i,:);

            stairs(obj.T, thresh)
            stairs(obj.T, err)
            
            legend('thresh', 'error')
        end
    end
end

