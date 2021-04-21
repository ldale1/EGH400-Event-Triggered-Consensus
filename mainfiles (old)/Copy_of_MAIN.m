% Cleanup
clc; close all;

%% Setup
% The agent dynamics
A = [0 1; 
     0 0;];
B = [0;
     1];
C = eye(size(A));
D = zeros(size(B));



%% Simulate
import ConsensusMAS.*;

% Simulation variables
SIZE = 5;


%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
X0 = [5.5 -4.5 12.5 9.5 -0.5;
      9.5 -6.5 -0.5 -1.5 2.5];
%%
import ConsensusMAS.*;

%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(A, 1), 1);
set = @(id) NaN * zeros(size(A, 1), 1);
K = @(id) lqr(A, B, 1, 1);

ts = 1/1e2;

% Create the network
network = Network(Implementations.GlobalEventTrigger, A, B, C, D, K, X0, ref, set, ts);

% Simulate with switching toplogies
%for t = 1:1
%    network.ADJ = ones(SIZE) - diag(ones(SIZE, 1));%RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 0);
%    network.Simulate('Fixed', 'time', 10);
%end

a1 = AgentFixedTrigger(1, A, B, C, D, K(1), X0(:,1), ref(1), set(0),  ts);
a2 = AgentFixedTrigger(2, A, B, C, D, K(2), X0(:,2), ref(2), set(0),  ts);
%https://github.com/ldale1/EGH400-Event-Triggered-Consensus/blob/double-staging/%2BConsensusMAS/%40Agent/Agent.m

a1.addReceiver(a2, 1);

a1.broadcast;

a2.transmissions_rx