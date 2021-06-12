import ConsensusMAS.*;

%% Model Structure
% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

% The agent dynamics
model_struct.linear = 0;
model_struct.numstates = 6;
model_struct.numinputs = 3;
model_struct.states = @(x, u) [...
    x(2); ...
    -x(2) + (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)); ...
    x(4); ...
    -x(4) + (u(1) + u(2))*sin(x(5)) + u(3)*cos(x(5)) ; ...
    x(6); ...
    u(1) - u(2) - x(6)];


% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

% Model linearisation
%{
f2x5 = @(u1, u2, x5) not0(  cos(x5)*(-(u1+u2))  );
f4x5 = @(u1, u2, x5) not0(  sin(x5)*(-(u1+u2))  );
model_struct.Af = @(x, u) [0  1  0  0  0  0;
              0  0  0  0  f2x5(u(1), u(2), x(5))  0;
              0  0  0  1  0  0;
              0  0  0  0  f4x5(u(1), u(2), x(5))  0;
              0  0  0  0  0  Jinv;
              0  0  0  0  0  -Jinv];
%}
model_struct.Af = @(x,u) [0 1 0 0 0 0;
          0 -1 0 0 not0(-(u(1)+u(2))*sin(x(5)) - u(3)*cos(x(5))) 0;
          0 0 0 1 0 0;
          0 0 0 -1 not0((u(1)+u(2))*cos(x(5)) - u(3)*sin(x(5))) 0;
          0 0 0 0 0 1;
          0 0 0 0 0 -1];
model_struct.Bf = @(x,u) [0 0 0;
          cos0(x(5)) cos0(x(5)) -sin0(x(5));
          0 0 0;
          sin0(x(5)) sin0(x(5)) cos0(x(5));
          0 0 0;
          1 -1 0]; 
 
 
%% Simulation  Structure
sim_struct.x_state = NaN;
sim_struct.vx_state = 1;
sim_struct.y_state = NaN;
sim_struct.vy_state = 3;

sim_struct.wind_states = [1 3];


%% Controller Specific Structure
clear controller_struct


Q = eye(model_struct.numstates) .* [1; 9; 1; 9; 1; 9];
R = 1;

% pole place
controller_struct.x_op = [0; 0; 0; 0; pi/4; 0];
controller_struct.u_op = [0; 0; 0];
controller_struct.Q = Q;
controller_struct.R = R;

% sliding
Qsmc = 1;
Rsmc = 1;

controller_struct.Qsmc = Qsmc;
controller_struct.Rsmc = Rsmc;
controller_struct.k = 15;
controller_struct.tau = 1;
%{
%controller_struct.n = numstates;
%controller_struct.m = numinputs;

targets = 128;             
controller_struct.map_state = @(x) mod(x(5), 2*pi);
controller_struct.round_targets = (-(2*pi/targets):(2*pi/targets):(2*pi)) + pi/targets;
controller_struct.target_x = @(target) [0; 0; 0; 0; target; 0];
controller_struct.target_u = @(target) [0; 0; 0];
%}

%% Simulation variables

% Interagent delta, and also setpoint
ref = @(id) zeros(size(model_struct.numstates, 1), 1);
set = @(id) [0; 0; 0; 0; 0; NaN];
set = @(id) [NaN*zeros(model_struct.numstates-1, 1); 0];

%{
scale_p = 100;
scale_p_dot = 5;
scale_theta = pi/4;
scale_theta_dot = 0.5;
%}

scale_p = 8;
scale_p_dot = 5;
scale_theta = pi/4;
scale_theta_dot = 0.5;

global x_generator;

if ~dynamic
    x_generator = @() [ ...
        scale_p*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_p*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_theta * ((rand()-0.5)/3+1) * sign(rand()-1/2);
        scale_theta_dot*(rand()-1/2)];
else
    x_generator = @() [ ...
        rand(); 
        rand(); 
        10 + 2*20*rand(); 
        (rand()-1/2)/10; 
        scale_theta*(1+(rand()-0.5)/10);
        scale_theta_dot*(rand()-1/2)];
end

X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));


%% Aux

function v = not0(v)
    cutoff = 0.001;
    if abs(v)<cutoff
        v = cutoff;
    end
end

function s = sin0(rad)
    s = sin(rad);
    cutoff = 0.001;
    if abs(s)<cutoff
        s = cutoff;
    end
end

function c = cos0(rad)
    c = cos(rad);
    cutoff = 0.001;
    if abs(c)<cutoff
        c = cutoff;
    end
end