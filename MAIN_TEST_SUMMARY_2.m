% Cleanup
%{
The initially developed unit tests have not been maintained with progress.
This file is a shoehorn to compensate.
%}
clc; close all;

%% Setup
import ConsensusMAS.*;

% The network
ADJ = [0 1 1 1 1; 
       1 0 1 1 1;
       1 1 0 1 1;
       1 1 1 0 1;
       1 1 1 1 0];

% The agent dynamics
A = 0;
B = 1;
C = eye(size(A));
D = zeros(size(B)); 
K = @(id) lqr(A, B, 1, 1);

% Initial conditions
X0 = [1 2 3 4 5 6 7 8 9];
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);


% Create the network and simulate
ts = 1/1e1;
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);
network.ADJ = ADJ;
network.Simulate('Fixed', 'time', 30);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;

%network.Plot3;
network.PlotErrors;

%network.Animate("test");