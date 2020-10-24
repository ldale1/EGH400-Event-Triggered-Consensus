% Cleanup
clc; close all;

%% Setup
import ConsensusMAS.*;

% The agent dynamics
A = 0;
B = 1;
C = eye(size(A));
D = zeros(size(B));
K = @(id) 1;

% Simulation variables
SIZE = 6;
ADJ = [0 0 1 0;
       1 0 0 0;
       0 1 0 0;
       0 0 1 0];
X0 = [-1 -2 1 3];
p = @(id) zeros(size(A, 2), 1);

% Create the network
ts = 0.3;
network = Network(Implementations.FiniteA, A, B, C, D, K, X0, p, ts);

% Simulate with switching toplogies
for t = 1:1
    network.ADJ = ADJ;
    network.Simulate('Fixed', 'time', 150);
end

%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates("plottype", "stairs");
network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
network.PlotErrors;
%network.Animate("title", "tester", "state1", 1, "state2", 3);
