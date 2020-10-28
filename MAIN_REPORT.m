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


%%

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
X0 = [randi(5*10, 1, SIZE)/10; 
      randi(2*10, 1, SIZE)/10;
      randi(5*10, 1, SIZE)/10;
      randi(1*10, 1, SIZE)/10];
  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
K = @(id) lqr(A, B, [5 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], 1);
ref = @(id) [0; 0; 0; 0];
set = @(id) [NaN; NaN; 0; 0];

ts = 1/1e1;

% Create the network
%network = Network(Implementations.FixedTrigger, A, B, C, D, K, X0, ref, set, ts);
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);
%network = Network(Implementations.LocalEventTrigger, A, B, C, D, K, X0, ref, set, ts);

% Simulate with switching toplogies
network.SimulateDynamic('Fixed', 'time', 200);


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("states", [1 3]);
%network.PlotErrors;
network.Animate("title", "cool1", "states", [1 3], "history", 1, "fixedaxes", [0 30 0 6]);

