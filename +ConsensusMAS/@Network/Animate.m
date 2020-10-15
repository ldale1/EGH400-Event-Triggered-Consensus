function obj = Animate(obj)
    % Create a figure animation and save    
    import ConsensusMAS.Utils.*
    assert(obj.agentstates == 2, "Wrong number of states");

    % This is two dimensional
    % inputs: agent x rows, steps x columns
    
    T = obj.T;
    X1 = zeros(obj.SIZE, length(T));
    X2 = zeros(obj.SIZE, length(T));
    TX = zeros(obj.SIZE, length(T));
    
    for agent = obj.agents
        X1(agent.id,:) = agent.X(1,:);
        X2(agent.id,:) = agent.X(2,:);
        TX(agent.id,:) = any(agent.TX);
    end

    % Create movie
    MovieMaker(T, X1, X2, TX);
end