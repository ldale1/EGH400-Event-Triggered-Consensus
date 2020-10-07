% Cleanup
clc; close all;

%% Setup
% The network
ADJ = [0 1 1 0 0;
       1 0 1 0 0;
       1 1 0 1 0;
       0 0 1 0 1;
       0 0 0 1 0];

% The agent dynamics
A = [-4 1; 
     4 -2];
B = [1 3; 
    -2 1];
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
X0 = [-6 3 10 -10 0;
      2 -5 -3 7 2];


%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 1/100, 'mintime', 6, 'maxtime', 50);

%network.PlotGraph
%network.PlotInputs;
%network.PlotStates;
network.Plot3;
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
network.PlotErrors;
%network.Animate;

