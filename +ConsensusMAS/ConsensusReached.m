function consensus = ConsensusReached(X0, X)
    range_x0 = max(X0) - min(X0);
    range_x = max(X) - min(X);
    consensus = range_x / range_x0 < 1/100;
end