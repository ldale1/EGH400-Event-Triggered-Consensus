% Cleanup
clc; close all;

%% Setup
% The network
ADJ = [0 1 1;
       1 0 1;
       1 1 0];

% The agent dynamics
A = [-4 1; 
     4 -2];
B = [1 3; 
    -2 1];
%B = [1; 0];
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
X0 = [-6 3 10;
      2 -5 -3];
%X0 = [-1 3 10 -10 0; 2 -5 -3 7 2];4


%% Simulate
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the network and simulate
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, ADJ);
network.Simulate('timestep', 1/100, 'mintime', 1, 'maxtime', 50);

%network.PlotGraph
%network.PlotInputs;
%network.PlotStates;
%network.Plot3;
%network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
%network.Animate;


figure(); hold on;
agent = 3;
%tx = network.Triggers(2,:,5);
t = network.T;
triggers = network.TX(1,:,agent);
err = network.ERROR(1,:,agent);
thresh = network.ERROR_THRESHOLD(1,:,agent);
    

stairs(t, thresh * network.agents(1).k)
stairs(t, err)
plot(t(logical(triggers)), err(logical(triggers)), '*');

legend('thresh', 'error')

%{

'
%

%A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0; 0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
%A = [0 1 1 0; 0 0 1 0; 1 0 0 1;  0 0 1 0]%; .* randi(SIZE, SIZE, SIZE);

SIZE = 5;
ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 1, 'strong', 1) * 0.1;
X0 = randi(5*SIZE, 2, SIZE) - 5*SIZE/2;
%}