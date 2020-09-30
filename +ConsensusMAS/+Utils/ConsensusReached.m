function consensus = ConsensusReached(X0, X)
    consensus = true;
    for i = 1:size(X, 1)
        X0i = squeeze(X0(i,:,:));
        Xi = squeeze(X(i,:,:));
        range_x0 = max(X0i) - min(X0i);
        range_x = max(Xi) - min(Xi);
        consensus = consensus & range_x / range_x0 < 1/100;
    end
end