% Cleanup
clc; close all;

%% Setup

%A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0; 0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
%A = [0 1 1 0; 0 0 1 0; 1 0 0 1;  0 0 1 0]%; .* randi(SIZE, SIZE, SIZE);





% The agent dynamics
A = [-4 0; 
     4 0];
B = [0 0; 
     0 1];
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
SIZE = 5;
%ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 1) * 0.1;
ADJ = [0 1 0 0 0;
       1 0 0 0 0;
       0 1 0 1 0;
       0 0 1 0 1;
       0 0 0 1 0];

X0 = randi(5*SIZE, size(A, 1), SIZE) - 5*SIZE/2;

%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 1/100, 'mintime', 1, 'maxtime', 50);

%network.PlotGraph
%network.PlotInputs;
%network.PlotStates;
network.Plot3;
network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
network.PlotErrors;
%network.Animate;


%{

'
%

%A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0; 0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
%A = [0 1 1 0; 0 0 1 0; 1 0 0 1;  0 0 1 0]%; .* randi(SIZE, SIZE, SIZE);

SIZE = 5;
ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 1) * 0.1;
X0 = randi(5*SIZE, 2, SIZE) - 5*SIZE/2;
%}