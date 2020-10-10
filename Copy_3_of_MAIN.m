% Cleanup
clc; close all;

%% Setup

%

%A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0; 0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
%A = [0 1 1 0; 0 0 1 0; 1 0 0 1;  0 0 1 0]%; .* randi(SIZE, SIZE, SIZE);



% The network
ADJ = [0 0 0 1 1 1;
       1 0 0 0 0 0;
       1 1 0 1 0 0;
       1 0 0 0 0 0;
       0 0 0 1 0 1;
       0 0 0 0 1 0];

% The agent dynamics
A = [-2 2; 
     -1 1];
B = [1;
     9];
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
X0 = [-6 3 10 -10 0 3;
      2 -5 -3 7 2 3];


%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 1/1e2, 'mintime', 6, 'maxtime', 15);


%network.PlotGraph;
%network.PlotInputs;
%network.PlotStates;
network.PlotTriggersStates;
network.Plot3;
network.PlotTriggers;
network.PlotErrors;
%network.Animate;