%% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

import ConsensusMAS.*;

% The agent dynamics
numstates = 6;
numinputs = 3;
states = @(x, u) [...
    x(2); ...
    (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)) - x(2); ...
    x(4); ...
    (u(1) + u(2))*sin(x(5)) + u(3)*cos(x(5)) - x(4); ...
    x(6); ...
    u(1) - u(2) - x(6)];

% Wind matrix
wind_states = [2 4];
  
% Interagent delta, and also setpoint
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);



A = @(x) [0 1 0 0 0 0;
          0 -1 0 0 0 0;
          0 0 0 1 0 0;
          0 0 0 -1 0 0;
          0 0 0 0 0 1;
          0 0 0 0 0 -1];
B = @(x) [0 0 0;
          cos(x(5)) cos(x(5)) -sin(x(5));
          0 0 0;
          sin(x(5)) sin(x(5)) cos(x(5));
          0 0 0;
          1 -1 0];
 
      
Q = [0 0 0 0 0 0;
     0 9 0 0 0 0;
     0 0 0 0 0 0;
     0 0 0 9 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 9];
R = 1;
K = @(id) (@(x) lqr(A(x), B(x), 1, 1)); %place(A(x), B(x), -7:1:-2));

% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
x0_1 = [+0.00 +0.10 +0.00 +0.00 +0.00 +0.26];
x0_2 = [+0.00 +0.00 +0.00 -1.00 +0.00 +0.39];
x0_3 = [+0.00 -0.20 +0.00 +5.00 +0.00 +0.11];
X0 = [x0_1', x0_2', x0_3'];