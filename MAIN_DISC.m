% Cleanup
clc; close all;

%% Setup
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% The agent dynamics
A = [-2 2;
     -1 1];
B = [1;
     0];
C = eye(size(A));
D = zeros(size(B));
K = @(id) [1 -2];

X0 = [0.4 0.5 0.6 0.7 0.8 0.4;
      0.3 0.2 0.1 0.0 -.1 -.2];
p = @(id) zeros(size(A, 1), 1);

ADJ = [0 0 0 1 1 1;
       1 0 0 0 0 0;
       1 1 0 1 0 0; % 4 shoudl talk to 3
       1 0 0 0 0 0;
       0 0 0 1 0 1;
       0 0 0 0 1 0];
Fa = GraphFrobenius(ADJ);

Fb = [4 0 0 1 3 2;
      5 5 0 0 0 0;
      3 2 5 0 0 0;
      5 0 0 5 0 0;
      0 0 0 4 4 2;
      0 0 0 0 3 7]/10;

  
%eig(Fa)
%eig(Fb)




%%

import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Simulation variables


% Create the network
ts = 0.2;
network = Network(Implementations.LocalEventTrigger, A, B, C, D, K, X0, p, ts);

% Simulate with switching toplogies
for t = 1:1
    network.ADJ = ADJ;
    network.Simulate('Fixed', 'time', 40);
end

%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
%network.Plot3("states", [1 3]);
network.PlotErrors;
%network.Animate("title", "tester", "states", [1 3]);

