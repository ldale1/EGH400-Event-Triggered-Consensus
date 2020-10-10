% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1;
     0 0];
B = [0;
     1];
C = eye(size(A));
D = zeros(size(B));


SIZE = 6;
ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 0);
X0 = [0.2*(1:SIZE);
      0.4*(1:SIZE)-1];




%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
%network.Simulate('timestep', 1/50, 'mintime', 100, 'maxtime', 100);
network.Simulate('timestep', 1/1e2, 'mintime', 30, 'maxtime', 100);

%network.PlotGraph
%network.PlotInputs;
%network.PlotTriggers;
network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.PlotErrors;
%network.Animate;
%network.Plot3;
