%% Setup
import ConsensusMAS.*;

% The agent dynamics
numstates = 6;
numinputs = 2;
states = @(x, u) [...
    x(2); ...
    -(u(1) + u(2))*sin(x(5)); ...
    x(4); ...
    (u(1) + u(2))*cos(x(5)); ...
    x(6); ...
    u(1) - u(2) - x(6)];

K = @(id) (@(x, u) x);

% Wind matrix
wind_states = [2 4];

% Interagent delta, and also setpoint
ref = @(id) zeros(numstates, 1);
set = @(id) [NaN*zeros(numstates-1, 1); 0];


Af = @(x, u) [0  1  0  0  0  0;
             0  0  0  0  -not0( (u(1)+u(2))*cos(x(5)) )  0;
             0  0  0  1  0  0;
             0  0  0  0  -not0( (u(1)+u(2))*sin(x(5)) )  0;
             0  0  0  0  0  1;
             0  0  0  0  0  -1];

Bf = @(x, u) ...
    [0 0;
     -sin0(x(5)) -sin0(x(5));
     0 0;
     cos0(x(5)) cos0(x(5));
     0 0;
     1 -1];

%% Controller Specific Info
Q = [0 0 0 0 0 0;
     0 9 0 0 0 0;
     0 0 0 0 0 0;
     0 0 0 9 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 9];
R = 1;

% pole place
controller_struct.x_op = [0 0 0 0 pi/4 0];
controller_struct.u_op = [0 0 0]';
controller_struct.Q = Q;
controller_struct.R = R;

% sliding
controller_struct.n = numstates;
controller_struct.m = numinputs;
controller_struct.k = 10;

targets = 128;             
controller_struct.map_state = @(x) mod(x(5), 2*pi);
controller_struct.round_targets = (-(2*pi/targets):(2*pi/targets):(2*pi)) + pi/targets;
controller_struct.target_x = @(target) [0; 0; 0; 0; target; 0];
controller_struct.target_u = @(target) [0; 0; 0];

%%

% Simulation variables
SIZE = 2;

% Random generator
scale_p = 1;
scale_p_dot = 1;
scale_theta = pi/4;
scale_theta_dot = 0.2;
x_generator = @() [ ...
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_theta*(rand()-1/2);
    scale_theta_dot*(rand()-1/2)];
X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));
    
X0 = X_generator(SIZE);

%{
x0_1 = [+10.00 +0.00 +0.00 +0.00 +0.00 0];
x0_2 = [+0.00 +0.00 +0.00 -1.00 +0.39 0];
x0_3 = [-2.00 -0.20 +0.00 +5.00 +0.11 0];
X0 = [x0_1', x0_2', x0_3'];
%}
function v = not0(v)
    if v==0
        v = 0.00001;
    end
end

function s = sin0(rad)
    s = sin(rad);
    if s==0
        s = 0.00001;
    end
end

function c = cos0(rad)
    c = cos(rad);
    if c==0
        c = 0.00001;
    end
end