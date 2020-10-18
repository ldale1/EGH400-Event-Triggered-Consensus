function L = GraphLaplacian(ADJ)
  
    I = eye(size(ADJ));
    DEG = diag(sum(ADJ, 2));
    L = DEG - ADJ;

end