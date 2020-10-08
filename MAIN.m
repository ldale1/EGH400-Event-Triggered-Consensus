% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1; 
     0 0];
B = [0 0;
     0 2];
C = eye(size(A));
D = zeros(size(B));


SIZE = 6;
ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 0) * 0.1;
X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;




%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 1/10, 'mintime', 20, 'maxtime', 30);

%network.PlotGraph
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
%network.PlotTriggersInputs;
network.PlotErrors;
%network.Animate;
%network.Plot3;
%network.PlotStates;