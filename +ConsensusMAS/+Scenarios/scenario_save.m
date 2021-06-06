function scenario_save(name, model, X0, ADJ, ts, runtime)
    import ConsensusMAS.Scenarios.path_save;
    save(...
        path_save(sprintf("%s.mat", name)), ... % Path
        'model', 'X0', 'ADJ', 'ts', 'runtime')  % variables
end

