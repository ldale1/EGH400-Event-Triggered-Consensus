%% Setup
import ConsensusMAS.*;

m= 0.5;
J= 0.0112;
bt= 1;
g= 9.8;
l= 0.2;

% The agent dynamics
numstates = 6;
numinputs = 2;
states = @(x, u) [...
    x(2)/m; ...
    -(u(1) + u(2))*sin(x(5)); ...
    x(4)/m; ...
    (u(1) + u(2))*cos(x(5)) - m*g; ...
    x(6)/J; ...
    l*u(1) - l*u(2) - x(6)/J];

K = @(id) (@(x) x);

% Wind matrix
wind_states = [2 4];
  
% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;

x0_1 = [+10.00 +0.00 +0.00 +0.00 +0.00 0];
x0_2 = [+0.00 +0.00 +0.00 -1.00 +0.39 0];
x0_3 = [-2.00 -0.20 +0.00 +5.00 +0.11 0];
X0 = [x0_1', x0_2', x0_3'];
  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);