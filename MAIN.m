% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1 0 0; 
     0 0 0 0;
     0 0 0 1;
     0 0 0 0];
B = [0 0;
     1 0;
     0 0;
     0 1];
C = eye(size(A));
D = zeros(size(B));


%% Simulate
import ConsensusMAS.*;

% Simulation variables
SIZE = 5;
X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;

%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
p = @(id) zeros(size(A, 1), 1);
K = @(id) lqr(A, B, 1, 1);

ts = 1/5e1;

% Create the network
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, p, ts);

% Simulate with switching toplogies
for t = 1:1
    network.ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 0);
    network.Simulate('Fixed', 'time', 75);
end

%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
network.PlotErrors;
%network.Animate("title", "tester", "state1", 1, "state2", 3);

