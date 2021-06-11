import ConsensusMAS.*;

%% Model Structure
% The agent dynamics
model_struct.linear = 0;
model_struct.numstates = 3;
model_struct.numinputs = 1;
model_struct.states = @(x, u) [...
    x(2); ...
    x(3); ...
    -(x(1)^2) + x(2) + u(1)];


% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

% Model linearisation
model_struct.Af = @(x, u) [0 1 0; ...
                           0 0 1; ...
                           -2*x(1) 1 0];
model_struct.Bf = @(x, u) [0; ...
                           0; ...
                           1];

%% Simulation  Structure
sim_struct.x_state = 1;
sim_struct.vx_state = 2;
sim_struct.y_state = 3;
sim_struct.vy_state = 4;

% Local Trigger specific
sim_struct.c = 0.1;

sim_struct.wind_states = [2];


%% Controller Specific Structure
clear controller_struct

% LQR
Q = eye(model_struct.numstates) .* [1; 1; 1];
R = 1;


% pole place
controller_struct.x_op = [0; 0; 0; 0]; % Linear don't care
controller_struct.u_op = [0; 1];
controller_struct.Q = Q;        % LQR
controller_struct.R = R;


% SMC
Qsmc = 3;
Rsmc = 1;

controller_struct.Qsmc = Qsmc;
controller_struct.Rsmc = Rsmc;
controller_struct.k = 5;
controller_struct.tau = 3;


%% Starting

% Interagent delta, and also setpoint
ref = @(id) zeros(model_struct.numstates, 1);
set = @(id) zeros(model_struct.numstates, 1);

% Random generator
scale_x1 = 10;
scale_x2 = 10;
x_generator = @() [ ...
    scale_x1*(rand()-1/2); 
    scale_x2*(rand()-1/2);
    scale_x1*(rand()-1/2)];
X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));

