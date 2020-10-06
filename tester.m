% Cleanup
clc; 

ts = 0.1;

% The agent dynamics
A = [-4 1; 
     4 -2];
B = [1 3; -2 1];
%B = [1; 1];


[G, H] = c2d(A, B, ts)
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
X0 = [-6; 2];
sys = ss(G, H, C, D, ts);
K = lqr(A, B, 1, 1);
sysFeedback = feedback(sys, K);


step(sysFeedback)