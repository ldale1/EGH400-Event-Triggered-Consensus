% Cleanup
clc; close all;

%% Setup

%

%A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0; 0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
%A = [0 1 1 0; 0 0 1 0; 1 0 0 1;  0 0 1 0]%; .* randi(SIZE, SIZE, SIZE);



% The network
ADJ = [0 1 1 0 0;
       1 0 1 0 0;
       1 1 0 1 0;
       0 0 1 0 1;
       0 0 0 1 0];

% The agent dynamics
m = 0.1;
A = [0 1/m 0 0;
     0 0 0 0;
     0 0 0 1/m;
     0 0 0 0];
B = -[0 0 0 0; 2 0 0 0; 0 0 0 0; 2 0 0 0];
C = ones(size(A));
D = zeros(size(A));

% Initial conditions
X0 = [-1 3 10 -10 0;
      2 -5 -3 7 2];

SIZE = 5;
ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 1) * 0.1;
X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;


%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 10e-3, 'mintime', 1, 'maxtime', 50);
%network.PlotGraph;
network.PlotInputs;
network.PlotStates;
network.PlotTriggers;
%network.Animate;

%{

figure(); hold on; grid on;
for agent = network.agents
    plot3(agent.X(1,:)', agent.X(2,:)', network.T')
end
xlabel('X')
ylabel('Y')
zlabel('T')
view(-70,30)
%}