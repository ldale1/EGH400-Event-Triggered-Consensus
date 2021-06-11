import ConsensusMAS.*;

%% Model Structure
% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

% The agent dynamics
model_struct.linear = 0;
model_struct.numstates = 8;
model_struct.numinputs = 3;
model_struct.states = @(x, u) [...
    x(2); ...
    x(3); ...
    (u(1) + u(2))*cos(x(7)) - u(3)*sin(x(7)) - x(3); ...
    x(5); ...
    x(6); ...
    (u(1) + u(2))*sin(x(7)) + u(3)*cos(x(7)) - x(6); ...
    x(8); ...
    u(1) - u(2) - x(8)];

% Which are relevant to consensus
model_struct.trigger_states = 1:model_struct.numstates;

model_struct.Af = @(x,u) [0 1 0 0 0 0 0 0;
          0 0 1 0 0 0 0 0;
          0 0 -1 0 0 0 (-(u(1)+u(2))*sin(x(7)) - u(3)*cos(x(7))) 0;
          0 0 0 0 1 0 0 0;
          0 0 0 0 0 1 0 0;
          0 0 0 0 0 -1 ((u(1)+u(2))*cos(x(7)) - u(3)*sin(x(7))) 0;
          0 0 0 0 0 0 0 1;
          0 0 0 0 0 0 0 -1];
model_struct.Bf = @(x,u) [0 0 0;
          0 0 0;
          cos(x(7)) cos(x(7)) -sin(x(7));
          0 0 0;
          0 0 0;
          sin(x(7)) sin(x(7)) cos(x(7));
          0 0 0;
          1 -1 0];
 
      
%% Simulation  Structure
sim_struct.x_state = 1;
sim_struct.vx_state = 2;
sim_struct.y_state = 4;
sim_struct.vy_state = 5;

sim_struct.wind_states = [sim_struct.vx_state, sim_struct.vy_state];


%% Controller Specific Info
Q = eye(model_struct.numstates) .* [1; 1; 9; 1; 1; 9; 1; 9];
R = 1;

% pole place
controller_struct.x_op = [0; 0; 0; 0; 0; 0; pi/4; 0];
controller_struct.u_op = [0; 0; 0];
controller_struct.Q = Q;
controller_struct.R = R;


% sliding
Qsmc = 1;
Rsmc = 1;

controller_struct.Qsmc = Qsmc;
controller_struct.Rsmc = Rsmc;
controller_struct.k = 1;
controller_struct.tau = 1;

%% Simulation variables

% Interagent delta, and also setpoint
ref = @(id) zeros(size(model_struct.numstates, 1), 1);
set = @(id) NaN * zeros(size(model_struct.numstates, 1), 1);

% Random generator
global x_generator;

if ~dynamic
    scale_x = 10;
    scale_p = 10;
    scale_p_dot = 10;
    scale_theta = pi;
    scale_theta_dot = 2;
    
    x_generator = @() [ ...
        scale_x*(rand()-1/2);
        scale_p*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_p*(rand()-1/2);
        scale_x*(rand()-1/2); 
        scale_p_dot*(rand()-1/2); 
        scale_theta*(rand()-1/2);
        scale_theta_dot*(rand()-1/2)];
else
    scale_theta = 0.9*pi;
    scale_theta_dot = 1;
    
    x_generator = @() [ ...
        1*(rand()-1/2);
        3*(rand()); 
        1*(rand()); 

        0.5 + 5*(rand());
        1*(rand()-1/2); 
        0.5*(rand()-1/2); 

        scale_theta*(rand()-1/2);
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