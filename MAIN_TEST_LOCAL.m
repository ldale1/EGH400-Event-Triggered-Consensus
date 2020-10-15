% Cleanup
clc; close all;

%% Setup

% The network
ADJ = [0 1 1;
       1 0 1;
       1 1 0];

% The agent dynamics
A = [0 1; 
     0 0];
B = [0 0;
     0 1];
C = eye(size(A));
D = zeros(size(B)); 

% Initial conditions
X0 = [-6 3 10;
      2 -5 -3];


%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
ts = 1/50;
network = Network(Implementations.LocalEventTrigger, A, B, C, D, X0, ADJ, ts);
network.Simulate('mintime', 6, 'maxtime', 61);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
network.Plot3;
network.PlotErrors;
%network.Animate;