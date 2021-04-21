%% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

import ConsensusMAS.*;


A = [0 1;  
     0 0];
B = [0; 
     1];
[G, H] = c2d(A, B, ts);

states_vz = [2];

% The agent dynamics
numstates = 2;
numinputs = 1;
states = @(x, u) A*x + B*u;

% State-dependent gain
%K_fix = place(A, B, -3:-1:-4)
%K_fix = place(G, H, -0.3:-0.1:-0.4)
K_fixed = dlqr(G, H, 1, 1);
K = @(id) (@(x) K_fix);
  
% Interagent delta, and also setpoint
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);

% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
x0_1 = [+0.00 +0.10];
x0_2 = [+5.00 +0.00];
x0_3 = [-2.00 -0.20];
X0 = [x0_1', x0_2', x0_3'];