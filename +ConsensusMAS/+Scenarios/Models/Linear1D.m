import ConsensusMAS.*;

%% Model Structure
% The agent dynamics
model_struct.linear = 1;
model_struct.numstates = 2;
model_struct.numinputs = 1;

% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

% Model linearisation
model_struct.Af = @(x, u) [0 1; 0 0];
model_struct.Bf = @(x, u) [0; 1];

%% Simulation  Structure
sim_struct.x_state = 1;
sim_struct.vx_state = 2;
sim_struct.y_state = NaN;
sim_struct.vy_state = NaN;

% Local Trigger specific
sim_struct.c = 0.1;

sim_struct.wind_states = 2;


%% Controller Specific Structure
clear controller_struct

% LQR
Q = eye(model_struct.numstates) .* [1; 1];
R = 1;

% pole place
controller_struct.x_op = [0 0]; % Linear don't care
controller_struct.u_op = 0;
controller_struct.Q = Q;        % LQR
controller_struct.R = R;

% SMC
Qsmc = 1;
Rsmc = 1;

controller_struct.Qsmc = Qsmc;
controller_struct.Rsmc = Rsmc;
controller_struct.k = 1;
controller_struct.tau = 1;


%% Starting

% Interagent delta, and also setpoint
ref = @(id) zeros(model_struct.numstates, 1);
set = @(id) NaN*zeros(model_struct.numstates, 1);
%set = @(id) zeros(model_struct.numstates, 1);

% Random generator
scale_x1 = 10;
scale_x2 = 20;
x_generator = @() [ ...
    scale_x1*(rand()-1/2); 
    2+scale_x2*(rand()-1/2)];
X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));



%{
%% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

import ConsensusMAS.*;

model_struct.linear = 1;

%{
A = [-1 2;  
      2 1];
B = [2; 
     1];
 %}
A = [0 1; 0 0];

B = [0; 1];
[G, H] = c2d(A, B, ts);

wind_states = [2];

% The agent dynamics
numstates = 2;
numinputs = 1;
states = @(x, u) A*x + B*u;

% State-dependent gain
%K_fix = place(A, B, -3:-1:-4)
%K_fix = place(G, H, -0.3:-0.1:-0.4)
K_fixed = dlqr(G, H, 1, 1);
K = @(id) (@(x, u) K_fixed);
  
% Interagent delta, and also setpoint
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);

% Simulation variables
SIZE = 3;

%X0 = randi(5*SIZE, size(A, 2), SIZE) - 5*SIZE/2;
x0_1 = [+1 +2];
x0_2 = [+5.00 +0.20];

X0 = [x0_1' x0_2'];

%x0_3 = [-2.00 -0.20];stick
%X0 = [x0_1', x0_2', x0_3'];

%}