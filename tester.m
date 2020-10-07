% Cleanup
clc; clear all;

ts = 0.001;

% The agent dynamics
A = [-4 1; 
     4 -2];
B = [1 3;
     -2 1];
K = [1/7 -3/7; 
    2/7 1/7];


[G, H] = c2d(A, B, ts);
C = eye(size(A));
D = zeros(size(B));

% Initial conditions
X0 = [-6; 2];
sys = ss(G, H, C, D, ts);
sysFeedback = feedback(sys, K);


[y, t] = initial(sysFeedback, X0)

figure()
plot(t, y)