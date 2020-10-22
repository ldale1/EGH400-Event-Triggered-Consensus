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
SIZE = 4;
X0 = (randi(SIZE, size(A, 2), SIZE) - SIZE/2) .* [1; 0; 1; 0];
X0(:,SIZE) = [0;0;0;0];
delta = @(id) SIZE * [0; 0; 0; 0];
ts = 1/1e2;

% Create the network
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, X0, delta, ts);

% Simulate with switching toplogies
network.ADJ = [0 1 1 1;
               1 0 1 1;
               1 1 0 1;
               0 0 0 0];
          
for i = 1:3
    if mod(i, 2)
        network.agents(4).x = [1; 0; -1; 0];
    else
        network.agents(4).x = [-1; 0; 1; 0];
    end
    
    
    %network.agents(4).x = [sin(i * 2*pi/333); 0; cos(i * 2*pi/333); 0];
    
    network.Simulate('Fixed', 'time', 10);
end


           


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
network.PlotErrors;
network.Animate("title", "tester",  "history", 20,  "fixedaxes", 1, "states", [1, 3]);

