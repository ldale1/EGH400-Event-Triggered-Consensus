% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1; 
     0 0];
B = [0;
     1];
C = eye(size(A));
D = zeros(size(B));

ADJ = [0 1 1 1 1;
       1 0 1 1 1;
       1 1 0 1 0;
       1 1 1 0 1;
       1 1 1 1 0];
%X0 = [-11 4 -10 1 10;
%      5 -17 9 11 1];
  
X0 = [5.5 -4.5 12.5 9.5 -0.5;
      9.5 -6.5 -0.5 -1.5 2.5];  
%% Simulate
import ConsensusMAS.*;

% Simulation variables
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);

K = @(id) lqr(A, B, 1, 1);

ts = 1/1e2;

% Create the network
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);

% Simulate with switching toplogies
for i = 1:1
    network.ADJ = ADJ;
    network.Simulate('Fixed', 'time', 15);
end


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
%network.Plot3("states", [1, 3]);
network.PlotErrors;
%network.Animate("title", "tester", "states", [1, 3]);

