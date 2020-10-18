% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1; 
     0 0];
B = [0 0;
     0 1];
C = eye(size(A));
D = zeros(size(B));

%SIZE = 6;
%ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 0) * 0.1;
%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
SIZE = 4;
%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
X0 = [4 1 2 3; 
      1 2 3 4];

%% Simulate
import ConsensusMAS.*;

% Create the network and simulate
ts = 1/1e3;
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ts);

% First adjacency
network.ADJ = [0 1 1 1;
               1 0 1 1;
               1 1 0 1;         
               1 1 1 0];
network.Simulate('Fixed', 'time', 2.5);

% Second adjacency
network.ADJ = [0 0 0 0;
               0 0 1 0;
               0 1 0 0;
               0 0 0 0];
network.Simulate('Fixed', 'time', 30);

% Third adjacency
network.ADJ = [0 1 1 1;
               1 0 1 1;
               1 1 0 1;         
               1 1 1 0];
network.Simulate('Dynamic', 'mintime', 30);


%network.Simulate('Dynamic', 'mintime', 500, 'maxtime', 50);
%network.Simulate('Style', 'FixedTime', 'mintime', 6, 'maxtime', 100);




%network.PlotEigs;
%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3;
network.PlotErrors;
%network.Animate("test");

