function F = GraphFrobenius(ADJ)
    
    I = eye(size(ADJ));
    DEG = diag(sum(ADJ, 2));
    F = (I + DEG)^-1 * (I + ADJ);
    
end
