% ET-SMC page 62
ts = 1/1e4;

A = [0 1; 
     0 0];
B = [0; 1]; 
[n,m] = size(B);

T = eye(2);

% Transform
Az = T * A * (T');
Bz = T * B;

% Sub-Matrices
A11 = Az(1:n-m, 1:n-m);
A12 = Az(1:n-m, n-m+1:end);
A21 = Az(n-m+1:end, 1:n-m);
A22 = Az(n-m+1:end, n-m+1:end);
B2 = Bz(n-m+1:end, 1:m);


%B2 = Bz(2:3, :);
C = [lqr(A11, A12, 3.5, 1), eye(1)];
%C = [-2 1];
k = 4;

x1 = [2; -1];
s1 = C * x1;
%u1 = -(C*Bz)^-1*(C*Az*z1 + (1-0.25)*C*z1 + k*sign(s1));
u1 = -(C*Bz)^-1*(C*Az*x1 + k*sign(s1));

X1 = x1;
S1 = s1;
U1 = u1;

for i = 1:1e5
    x1 = x1 + (A*x1 + B*u1)*ts;
    s1 = C * x1;
    u1 = -(C*Bz)^-1*(C*Az*x1 + k*sign(s1));

    X1 = [X1 x1];
    S1 = [S1 s1];
    U1 = [U1 u1];
end

%%
figure(), hold on;
for i = 1:n
    plot(X1(i,:)', 'DisplayName', sprintf("X%d", i))
    legend()
end
grid on

%%
figure(), hold on;
for i = 1:m
    plot(U1(i,:)', 'DisplayName', sprintf("U%d", i))
    legend()
end
grid on

%%
figure(), hold on;
for i = 1:m
    plot(S1(i,:)', 'DisplayName', sprintf("S%d", i))
    legend()
end
grid on


save('CONT.mat', 'X1', 'S1', 'U1');
