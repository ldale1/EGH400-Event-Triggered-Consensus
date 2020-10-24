% Cleanup
clc; close all;

%% Setup
import ConsensusMAS.*;

% The network
ADJ = [0 1 1 0 0; 1 0 1 0 0; 1 1 0 1 0 ; 0 0 1 0 1; 0 0 0 1 0];

% The agent dynamics
A = [-4 1;  4 -2];
B = [1 3; -2 1];
C = eye(size(A));
D = zeros(size(B)); 
K = @(id) [1/7 -3/7; 2/7 1/7];

% Initial conditions
X0 = [-6 3 10 -10 0; 2 -5 -3 7 2];
p = @(id) zeros(size(A, 1), 1);

% Create the network and simulate
ts = 1/1e3;
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, p, ts);
network.ADJ = ADJ;
network.Simulate('Fixed', 'time', 6);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;

network.Plot3;
network.PlotErrors;

%network.Animate("test");