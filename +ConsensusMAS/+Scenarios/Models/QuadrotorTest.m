import ConsensusMAS.*;

%% Model Structure
Jinv = 3; % This magnifies x5_dot by Jinv^2

% The agent dynamics
model_struct.linear = 0;
model_struct.numstates = 6;
model_struct.numinputs = 2;
model_struct.states = @(x, u) [...
    x(2); ...
    -(u(1) + u(2))*sin(x(5)); ...
    x(4); ...
    +(u(1) + u(2))*cos(x(5)); ...
    x(6)*Jinv; ...
    u(1) - u(2) - x(6)*Jinv];

% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

% Model linearisation
f2x5 = @(u1, u2, x5) not0(  cos(x5)*(-(u1+u2))  );
f4x5 = @(u1, u2, x5) not0(  sin(x5)*(-(u1+u2))  );
model_struct.Af = @(x, u) [0  1  0  0  0  0;
              0  0  0  0  f2x5(u(1), u(2), x(5))  0;
              0  0  0  1  0  0;
              0  0  0  0  f4x5(u(1), u(2), x(5))  0;
              0  0  0  0  0  Jinv;
              0  0  0  0  0  -Jinv];
model_struct.Bf = @(x, u) ...
    [0 0;
     -sin0(x(5)) -sin0(x(5));
     0 0;
     +cos0(x(5)) +cos0(x(5));
     0 0;
     1 -1];
 
 
%% Simulation  Structure
sim_struct.x_state = 1;
sim_struct.vx_state = 2;
sim_struct.y_state = 3;
sim_struct.vy_state = 4;

sim_struct.wind_states = [2 4];

%% Controller Specific Structure
clear controller_struct

% Q_6 is important
Q = 100*eye(model_struct.numstates) .* [15; 15; 15; 15; 1; 1];


% Lower R causes theta to adjust faster, as inputs aren't penalised
%         this also means more events are triggered!
R = 1;

% pole place
controller_struct.x_op = [0 0 0 0 pi/4 0];
controller_struct.u_op = [0 0 0]';
controller_struct.Q = Q;
controller_struct.R = R;

% sliding
Qsmc = 1; %eye(4).*[8; 1; 1; 1];
Rsmc = 1;

controller_struct.Qsmc = Qsmc;
controller_struct.Rsmc = Rsmc;
controller_struct.k = 3;
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

%%

% Simulation variables

% Interagent delta, and also setpoint
ref = @(id) zeros(model_struct.numstates, 1);
set = @(id) [zeros(model_struct.numstates-1, 1); 0];
set = @(id) [0; 0; 0; 0; 0; 0];
set = @(id) [NaN*zeros(model_struct.numstates-1, 1); 0];

% Random generator
%{
scale_p = 200;
scale_p_dot = 20;
scale_theta = pi/4;
scale_theta_dot = 2;

scale_p = 5;
scale_p_dot = 1;
scale_theta = pi/8;
scale_theta_dot = .1;
%}

scale_p = 10;
scale_p_dot = 0;
scale_theta = pi/4;
scale_theta_dot = 0;

global x_generator;

if ~dynamic
    x_generator = @() [ ...
        scale_p*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_p*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_theta*(1+(rand()-0.5)/2);
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