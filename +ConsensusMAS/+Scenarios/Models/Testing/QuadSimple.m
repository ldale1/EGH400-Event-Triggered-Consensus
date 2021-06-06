%% Setup
import ConsensusMAS.*;

m= 0.5;
J= 0.0112;
bt= 1;
g= 9.8;
l= 0.2;


% The agent dynamics
numstates = 4;
numinputs = 2;
states = @(x, u) [...
    x(2); ...
    -(u(1) + u(2))*sin(x(3)); ...
    x(4); ...
    u(1) - u(2) - x(4)];
% Wind matrix
wind_states = [2 4];
  
% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;

  
%p = @(id) SIZE * [sin(2*pi*id/SIZE); 0; cos(2*pi*id/SIZE); 0];
ref = @(id) zeros(numstates, 1);
%set = @(id) [NaN * zeros(numstates-1, 1); 0];
set = @(id) NaN * zeros(numstates, 1);

% Gain Scheduling
A = @(x) [0  1  0  0;
          0  0  0  0;
          0  0  0  1;
          0  0  0 -1;];
      
x = repmat(0, 1, numstates);



B = @(x) ...
    [0 0;
     -not0(sin(x(3))) -not0(sin(x(3)));
     0 0;
     1 -1];
Q = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 10];
K = @(id) (@(x) lqr(A(x), B(x), Q, 1));


x0_1 = [+0.00 +0.10 +0.00 +0.00];
x0_2 = [+0.00 +0.00 +0.00 -1.00];
x0_3 = [+0.00 -0.20 +0.00 +1.00];
X0 = [x0_1', x0_2', x0_3'];

function v = not0(v)
    if v==0
        v = 0.00001;
    end
end