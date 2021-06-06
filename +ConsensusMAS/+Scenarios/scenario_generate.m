%% Report 1

% scenario label
name = "Report_VConsensusAlgorithmExploration";

% scenario variables
model = "Linear1D";
X0 = [5.5, -4.5, 12.5, 9.5, -0.5;
      9.5, -6.5, -0.5, -1.5, 2.5];
ADJ = ones(5) - eye(5);
ts = 1/1e2;
runtime = 10;

% Save for later
ConsensusMAS.Scenarios.scenario_save(name, model, X0, ADJ, ts, runtime);

%{
save(...
    path_save(sprintf("%s.mat", name)), ...     % Path
    'model', 'X0', 'ADJ', 'ts', 'runtime');     % Variables
%}


%% Report 2



%% ...