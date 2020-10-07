function obj = Animate(obj)
    % Create a figure animation and save
    import ConsensusMAS.Utils.*;

    % So far this is only two dimensional
    % inputs: agent x rows, steps x columns

    % inputs
    x = squeeze(obj.X(1,:,:))';
    y = ones(obj.SIZE, length(obj.T)) .* (1:obj.SIZE)';
    tx = squeeze(obj.TX(1,:,:))';

    % Update if there was more than a single state
    if (obj.agentstates > 1)
        y = squeeze(obj.X(2,:,:))';
        tx = logical(squeeze(any(obj.TX(1:2,:,:))))';
    end

    % Create movie
    MovieMaker(obj.T, x, y, tx);
end