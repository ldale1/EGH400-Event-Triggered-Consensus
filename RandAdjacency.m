function A = RandAdjacency(SIZE, varargin)
    
    strong = false;
    directed = false;
    weighted = false;

    for k = 1:length(varargin)
        if (strcmp(varargin{k}, "weighted"))
            k = k + 1;
            weighted = varargin{k};
        end
        
        if (strcmp(varargin{k}, "directed"))
            k = k + 1;
            directed = varargin{k};
        end
        
        if (strcmp(varargin{k}, "strong"))
            k = k + 1;
            strong = varargin{k};
        end 
    end
    
    % Strongly connected all can talk to each other
    if strong
        A = ones(SIZE, SIZE) - eye(SIZE);
    else
        A = max(randi(2, SIZE, SIZE) - 1  - eye(SIZE), 0);
    end
    
    
    % Multiply by random weights
    if weighted 
        A = A .* randi(SIZE, SIZE, SIZE);
    end
    
    % Type
    if ~directed
        A = tril(A, -1) + tril(A,-1)';
    end
end
