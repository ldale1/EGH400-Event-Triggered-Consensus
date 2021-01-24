function exit_func = ExitFuncFixed(t, varargin)
    % parse args
    % Unpackage repacked args
    % TODO: Fix this up... shouldn't need args
    endtime = t;
    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "time"))
            endtime = varargin{k + 1} + t;
        end
    end
    exit_func = @(t, c) (round(t - endtime, 6) >= 0);
end