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

%adjs = [network.TOPS.ADJ]
%% Simulate
import ConsensusMAS.*;

% Simulation variables
SIZE = 5;
X0 = [5.5 -4.5 12.5 9.5 -0.5;
      9.5 -6.5 -0.5 -1.5 2.5];  
  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);
K = @(id) lqr(A, B, 1, 1);

ts = 1/1e2;

% Create the network
%network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);
network = Network(Implementations.LocalEventTrigger, A, B, C, D, K, X0, ref, set, ts);

% Simulate with switching toplogies
%for t = 1:1
%    network.ADJ = ones(SIZE) - eye(SIZE);
%    network.Simulate('Fixed', 'time', 10);
%end

for i = 1:1
    %network.ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 0);
    %network.ADJ = adjs(:,(i-1)*5+1:i*5)
    network.ADJ = ones(SIZE) - eye(SIZE);
    network.Simulate('Fixed', 'time', 10);
end



network.PlotGraph;
network.PlotStates;
network.PlotInputs;
network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
for i = 1:length(network.agents)
    network.agents(i).ERROR(:,1) = [0;0];
    %network.agents(i).ERROR(:,2) = [0;0];
end

network.PlotErrors;
%network.Animate("title", "tester", "state1", 1, "state2", 3);

