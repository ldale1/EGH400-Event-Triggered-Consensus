%% Dynamics
% https://ieeexplore-ieee-org.ezp01.library.qut.edu.au/document/1384698

import ConsensusMAS.*;

% The agent dynamics
numstates = 6;
numinputs = 3;
states = @(x, u) [...
    x(2); ...
    -x(2) + (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)); ...
    x(4); ...
    -x(4) + (u(1) + u(2))*sin(x(5)) + u(3)*cos(x(5)) ; ...
    x(6); ...
    u(1) - u(2) - x(6)];

% Wind matrix
wind_states = [1 3];
  
% Interagent delta, and also setpoint
ref = @(id) zeros(size(numstates, 1), 1);
set = @(id) NaN * zeros(size(numstates, 1), 1);

Af = @(x,u) [0 1 0 0 0 0;
          0 -1 0 0 not0(-(u(1)+u(2))*sin(x(5)) - u(3)*cos(x(5))) 0;
          0 0 0 1 0 0;
          0 0 0 -1 not0((u(1)+u(2))*cos(x(5)) - u(3)*sin(x(5))) 0;
          0 0 0 0 0 1;
          0 0 0 0 0 -1];
Bf = @(x,u) [0 0 0;
          cos0(x(5)) cos0(x(5)) -sin0(x(5));
          0 0 0;
          sin0(x(5)) sin0(x(5)) cos0(x(5));
          0 0 0;
          1 -1 0];
 
      

%% Controller Specific Info
Q = [1 0 0 0 0 0;
     0 9 0 0 0 0;
     0 0 1 0 0 0;
     0 0 0 9 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 9];
R = 1;

% pole place
controller_struct.x_op = [0 0 0 0 pi/4 0];
controller_struct.u_op = [0;0;0];
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

%% Simulation variables

SIZE = 3;

% Random generator
scale_p = 200;
scale_p_dot = 10;
scale_theta = pi;
scale_theta_dot = 2;
x_generator = @() [ ...
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_theta*(rand()-1/2);
    scale_theta_dot*(rand()-1/2)];
X_generator = @(num_agents) cell2mat(arrayfun(@(x) {x_generator()}, 1:num_agents));
    
X0 = X_generator(SIZE);

% SCENARIO ONE
%{
x0_1 = [+5.00 +1.00 -8.00 -3.00 3*pi/8 -1];
x0_2 = [+1.00 -6.00 +2.00 +5.00  pi/8 -1];
x0_3 = [-13.00 -0.20 +4.00 -1.00 pi/24 +1];
%}

% SCENARIO TWO
%{
x0_1 = [+5.00 +1.00 -8.00 -3.00 3*pi/8 -5];
x0_2 = [+1.00 -6.00 +2.00 +5.00  pi/8 -3];
x0_3 = [-13.00 -0.20 +4.00 -1.00 pi/24 +3];


X0 = [x0_1', x0_2', x0_3'];
%}







function v = not0(v)
    if v==0
        v = 0.001;
    end
end

function s = sin0(rad)
    s = sin(rad);
    if s==0
        s = 0.001;
    end
end

function c = cos0(rad)
    c = cos(rad);
    if c==0
        c = -0.001;
    end
end
