% Cleanup
clc; close all;

%% Setup

% The network
ADJ = [0 1 1 0 0;
       1 0 1 0 0;
       1 1 0 1 0 ;
       0 0 1 0 1;
       0 0 0 1 0];

% The agent dynamics
A = [0 1; 
     -1 0];
B = [1 0;
     0 1];
C = eye(size(A));
D = zeros(size(B)); 

% Initial conditions
X0 = [-6 3 10 -10 0;
      2 -5 -3 7 2];


%% Simulate
import ConsensusMAS.*;

% Create the network and simulate
ts = 1/50;
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ts);

network.ADJ = ADJ;
network.Simulate("Dynamic", 'mintime', 8, 'maxtime', 10);

%network.ADJ = zeros(size(ADJ));
%network.Simulate("Dynamic", 'mintime', 6);


network.PlotGraph;

network.PlotStates;
network.PlotInputs;
network.PlotTriggers;

network.PlotTriggersStates;
network.PlotTriggersInputs;



network.Plot3;
network.PlotErrors;

network.Animate("test");