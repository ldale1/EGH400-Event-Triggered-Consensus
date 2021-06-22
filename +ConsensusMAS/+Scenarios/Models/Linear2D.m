import ConsensusMAS.*;

%% Model Structure
% The agent dynamics
model_struct.linear = 1;
model_struct.numstates = 4;
model_struct.numinputs = 2;

% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

% Model linearisation
model_struct.Af = @(x, u) [0 1 0 0; ...
                           0 0 0 0; ...
                           0 0 0 1; ...
                           0 0 0 0];
model_struct.Bf = @(x, u) [0 0; ...
                           1 0; ...
                           0 0; ...
                           0 1];

%% Simulation  Structure
sim_struct.x_state = 1;
sim_struct.vx_state = 2;
sim_struct.y_state = 3;
sim_struct.vy_state = 4;

% Local Trigger specific
sim_struct.c = 0.1;

sim_struct.wind_states = [2 4];


%% Controller Specific Structure
clear controller_struct

% LQR
Q = eye(model_struct.numstates) .* [1; 1; 1; 1];
R = 1;





% pole place
controller_struct.x_op = [0; 0; 0; 0]; % Linear don't care
controller_struct.u_op = [0; 1];
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
global x_generator;

if ~dynamic
    x_generator = @() [ ...
        1*(rand()-1/2); 
        1*(rand()-1/2); 
        1*(rand()-1/2); 
        1*(rand()-1/2); ];
else
    x_generator = @() [ ...
        50*rand(); 
        3 + rand()*4; 
        20*round(randi(4)); 
        0];
end
X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));


X0 = X_generator(35)
x_generator = @() [ ...
        0; 
        1 + rand()*4; 
        10 + 5*20*rand(); 
        2*(rand()-0.5)];