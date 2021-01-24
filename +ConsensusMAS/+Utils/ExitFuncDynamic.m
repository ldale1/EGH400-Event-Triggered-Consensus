function exit_func = ExitFuncDynamic(t, varargin)
    % parse args
    % Unpackage repacked args
    mintime = 0;
    maxtime = 1e5;
    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "mintime"))
            mintime = varargin{k + 1} + t;
        elseif (strcmp(varargin{k}, "maxtime"))
            maxtime = varargin{k + 1} + t;
        end
    end
    exit_func = @(t, c) (...
        ((round(t - mintime, 6) >= 0) && c) ||  t > maxtime);
end