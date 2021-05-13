%
% Sliding for a two agents
%

close all;
Af = @(x,u) [0 1 0 0 0 0;
          0 -1 0 0 (-(u(1)+u(2))*sin(x(5)) - u(3)*cos(x(5))) 0;
          0 0 0 1 0 0;
          0 0 0 -1 ((u(1)+u(2))*cos(x(5)) - u(3)*sin(x(5))) 0;
          0 0 0 0 0 1;
          0 0 0 0 0 -1];
Bf = @(x,u) [0 0 0;
          cos(x(5)) cos(x(5)) -sin(x(5));
          0 0 0;
          sin(x(5)) sin(x(5)) cos(x(5));
          0 0 0;
          1 -1 0];
      
x = [0; 0; 0; 0; pi/8; 0];
u1 = [0; 0; 0];

A = Af(x, u1)
B = Bf(x, u1)
      

[Tr1, Temp] = qr(B);
%Tr1f = Tr1^-1;
Tr1f = Tr1';
T = [Tr1f(m+1:n,:);Tr1f(1:m,:)];


n = 6;
m = 3;

Az = T * A * (T');
A11 = Az(1:n-m, 1:n-m)
A12 = Az(1:n-m, n-m+1:end)
A21 = Az(n-m+1:end, 1:n-m)
A22 = Az(n-m+1:end, n-m+1:end)

Bz = T * B;
B2 = Bz(n-m+1:end, :)

C1 = place(A11, A12, -2:-1:-4);%lqr(A11, A12, 1, 1)
C = [C1, eye(n-m)]

ts = 0.001;

k = 10;

x1 = [3; 2; -1; -4; 1; 13];
x2 = [3; 2; -1; -4; 1; 2] + 3;

z1 = T * x1;
z2 = T * x2;

X1 = [];
X2 = [];

Z1 = [];
Z2 = [];

S1 = [];
S2 = [];

U1 = [];
U2 = [];


for i = 1:10000
    z1d = z1 - z2;
    z2d = z2 - z1;
    
    s1 = C * z1d;
    u1 = -(C*Bz)^-1*(C*Az*z1d + k*sign(s1));

    s2 = C * z2d;
    u2 = -(C*Bz)^-1*(C*Az*z2d + k*sign(s2));
    
    %
    X1 = [X1 x1];
    Z1 = [Z1 z1];
    S1 = [S1 s1];
    U1 = [U1 u1];
    
    X2 = [X2 x2];
    Z2 = [Z2 z2];
    S2 = [S2 s2];
    U2 = [U2 u2];
    
    x1 = x1 + (A * x1 + B * u1) * ts;
    x2 = x2 + (A * x2 + B * u2) * ts;
    
    z1 = z1 + (Az * z1 + Bz * u1) * ts;
    z2 = z2 + (Az * z2 + Bz * u2) * ts;
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(Z1(i,:)', 'DisplayName', "A1")
    plot(Z2(i,:)', 'DisplayName', "A2")
    legend()
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(X1(i,:)', 'DisplayName', "A1")
    plot(X2(i,:)', 'DisplayName', "A2")
    legend()
end

figure();
for i = 1:m
    subplot(m, 1, i), hold on;
    plot(U1(i,:)', 'DisplayName', "A1")
    plot(U2(i,:)', 'DisplayName', "A2")
    legend()
end

figure();
for i = 1:n-m
    subplot(n-m, 1, i), hold on;
    plot(S1(i,:)', 'DisplayName', "A1")
    plot(S2(i,:)', 'DisplayName', "A2")
    legend()
end