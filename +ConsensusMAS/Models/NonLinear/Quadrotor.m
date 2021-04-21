%% Setup
import ConsensusMAS.*;

% The agent dynamics
numstates = 6;
numinputs = 2;
states = @(x, u) [...
    x(2); ...
    (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)); ...
    x(4); ...
    (u(1) + u(2))*sin(x(5)) - u(3)*cos(x(5)); ...
    u(1) - u(2)];

% Wind matrix
states_vz = [2 4];
  
% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;

x0_1 = [+0.00 +0.10 +0.00 +0.00 +0.26];
x0_2 = [+0.00 +0.00 +0.00 -1.00 +0.39];
x0_3 = [+0.00 -0.20 +0.00 +5.00 +0.11];
X0 = [x0_1', x0_2', x0_3'];
  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);

% Gain Scheduling
A = @(x) [0  1  0  0  0  0;
          0  0  0  0  0  0;
          0  0  0  1  0  0;  
          0  0  0  0  0  0;
          0  0  0  0  0  1;
          0  0  0  0  0 -1];
      
x = repmat(pi/1.5, 1, 6);

B = @(x) ...
    [0 0;
     -sin(x(5)) -sin(x(5));
     0 0;
     cos(x(5)) cos(x(5));
     0 0;
     1 -1];

K = @(id) (@(x) place(A(x), (x), -2:-1:-6));

K = @(x) place(A(x), B(x), -2:-1:-7);

Cab = ctrb(A(x), B(x))
rank(Cab)


%%

%% Setup
import ConsensusMAS.*;

% The agent dynamics
numstates = 6;
numinputs = 2;
states = @(x, u) [...
    x(2); ...
    (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)); ...
    x(4); ...
    (u(1) + u(2))*sin(x(5)) - u(3)*cos(x(5)); ...
    u(1) - u(2)];

% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;

x0_1 = [+0.00 +0.10 +0.00 +0.00 +0.26];
x0_2 = [+0.00 +0.00 +0.00 -1.00 +0.39];
x0_3 = [+0.00 -0.20 +0.00 +5.00 +0.11];
X0 = [x0_1', x0_2', x0_3'];
  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);

% Gain Scheduling
A = @(x) [0  1  0  0  0;
          0  0  0  0  0;
          0  0  0  1  0;
          0  0  0  0  -1
          0  0  0  0  0];
      
x = repmat(pi/1.5, 1, 6);

B = @(x) ...
    [0 0 0;
     -sin(x(5)) -sin(x(5)) 0;
     0 0 0;
     cos(x(5)) cos(x(5)) 0;
     0 0 0];

K = @(id) (@(x) place(A(x), (x), -2:-1:-6));

K = @(x) place(A(x), B(x), -2:-1:-7);

Cab = ctrb(A(x), B(x))
rank(Cab)
