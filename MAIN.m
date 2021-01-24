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


%% Simulate
import ConsensusMAS.*;

% Simulation variables
SIZE = 2;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
X0 = [5.5 -4.5;
      9.5 -6.5];
%%
import ConsensusMAS.*;

%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);
K = @(id) lqr(A, B, 1, 1);
ts = 1/1e2;

% Create the network
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);
network.ADJ = [0 1;  1 0];
network.Simulate('Fixed', 'time', 30);
network.PlotTriggersStates;
