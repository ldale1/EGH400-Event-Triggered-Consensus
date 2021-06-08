% ET-SMC page 62
ts = 1/1e2;

A = [0 1; 
     0 0];
B = [0; 1]; 
[n,m] = size(B);


[G, H] = c2d(A, B, ts);

A = G;
B = H;

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
C = [dlqr(A11, A12, 2, 1), eye(1)];
%C = [-2 1];
k = 4*ts;

x1 = [2; -1];
s1 = C * x1;
%u1 = -(C*Bz)^-1*(C*Az*z1 + (1-0.25)*C*z1 + k*sign(s1));
u1 = -(C*Bz)^-1*(C*Az*x1 - (1-ts)*s1 + k*sign(s1));

Xd1 = x1;
Sd1 = s1;
Ud1 = u1;

for i = 1:(1/ts)*10
    x1 = (G*x1 + H*u1);
    s1 = C * x1;
    u1 = -(C*Bz)^-1*(C*Az*x1 - (1-ts)*s1 + k*sign(s1));

    Xd1 = [Xd1 x1];
    Sd1 = [Sd1 s1];
    Ud1 = [Ud1 u1];
end

%%
figure(), hold on;
for i = 1:n
    plot(Xd1(i,:)', 'DisplayName', sprintf("X%d", i))
    legend()
end
grid on

%%
figure(), hold on;
for i = 1:m
    plot(Ud1(i,:)', 'DisplayName', sprintf("U%d", i))
    legend()
end
grid on

%%
figure(), hold on;
for i = 1:m
    plot(Sd1(i,:)', 'DisplayName', sprintf("S%d", i))
    legend()
end
grid on
