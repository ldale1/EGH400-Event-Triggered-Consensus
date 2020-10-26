% Cleanup
clc; close all;

%% Setup
import ConsensusMAS.*;

% The network
ADJ = [0 1 1 0; 
       0 0 1 1;
       0 0 0 1;
       1 0 0 0];

% The agent dynamics
A = [0.0  1.0;  
     0.0 -0.4];
B = [0.8;
     0.5];
C = eye(size(A));
D = zeros(size(B)); 
K = @(id) [0.1070 0.3497];

% Initial conditions
X0 = [0.0 0.5 -1.0  0.5; 
      1.0 1.5  0.0 -0.5];
p = @(id) zeros(size(A, 1), 1);

% Create the network and simulate
ts = 1/1e1;
network = Network(Implementations.SampledEventTrigger, A, B, C, D, K, X0, p, ts);
network.ADJ = ADJ;
network.Simulate('Fixed', 'time', 30);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;

network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;

network.Plot3;
network.PlotErrors;

%network.Animate("test");