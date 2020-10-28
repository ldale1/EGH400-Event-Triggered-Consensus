%% EX1. 
import ConsensusMAS.*;
clc; close all;

% The agent dynamics
A = [0 1;  
     0 0];
B = [0;
     1];
C = eye(size(A));
D = zeros(size(B)); 
K = @(id) lqr(A, B, 1, 1);

% Initial conditions
ADJ = [0 1 1 0 0 0;
       1 0 1 0 0 0;
       1 1 0 0 0 0;
       0 0 0 0 0 0;
       0 0 0 1 0 0;
       0 0 0 0 0 0];
X0 = [1 2 3 6 8 10; 
      -1.5 0 1 1 3 3];
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);

 

% Create the network and simulate
ts = 1/1e2;
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);
network.ADJ = ADJ;
network.Simulate('Fixed', 'time', 60);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;

network.Plot3;
network.PlotErrors;

%network.Animate("test");