% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1; 
     0 0];
B = [0 0;
     0 1];
C = eye(size(A));
D = zeros(size(B));

%SIZE = 6;
%ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 0) * 0.1;
%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
SIZE = 4;
ADJ = [0 1 1 1;
       1 0 1 1;
       1 1 0 1;
       1 1 1 0];
%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
X0 = [4 1 2 3; 1 2 3 4];

%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% sim settings
ts = 1/10;
mintime = 50;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ, ts);
network.Simulate('timestep', 1/100, 'mintime', mintime, 'maxtime', mintime + 1);

%network.PlotGraph
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
%network.PlotTriggersInputs;
network.PlotErrors;

%network.Animate;
%network.Plot3;
