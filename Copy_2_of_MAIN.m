% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [-2 1; 
     0 0];
B = [1 0;
     0 1];
C = eye(size(A));
D = zeros(size(B));


SIZE = 2;
%ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 1) * 0.1;
ADJ = [0 1;
       1 0];
X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;




%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
%network.Simulate('timestep', 1/50, 'mintime', 100, 'maxtime', 100);
network.Simulate('timestep', 1/50, 'mintime', 50, 'maxtime', 101);

%network.PlotGraph
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.PlotErrors;
%network.Animate;
%network.Plot3;
%network.PlotStates;