%
% Single agent
%

close all; clear all;

fx = @(x, u) [...
    x(2); ...
    (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)) - x(2); ...
    x(4); ...
    (u(1) + u(2))*sin(x(5)) + u(3)*cos(x(5)) - x(4); ...
    x(6); ...
    u(1) - u(2) - x(6)];


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
Tr1f = Tr1^-1;
T = [Tr1f(4,:),
    Tr1f(5,:),
    Tr1f(6,:),
    Tr1f(1,:),
    Tr1f(2,:),
    Tr1f(3,:)];

n = 6;
m = 3;

Az = T * A * (T');
A11 = Az(1:n-m, 1:n-m)
A12 = Az(1:n-m, n-m+1:end)
A21 = Az(n-m+1:end, 1:n-m)
A22 = Az(n-m+1:end, n-m+1:end)

Bz = T * B;
B2 = Bz(n-m+1:end, :)

%C = [-0.1538 1 0; 0.2308 0 1];
%C = [-0.1967 1 0; 0.1639 0 1];
Q = [55 0 0;
    0 1 0;
    0 0 1];
C1 = lqr(A11, A12, 1, 1)
C = [C1, eye(n-m)]

ts = 0.001;

k = 2;

x1 = [3; 2; -1; -4; 1; 1];
z1 = T * x1;


s1 = zeros(m, 1);
u1 = zeros(m, 1);

Z1 = z1;
X1 = x1;
S1 = s1;
U1 = u1;

for i = 1:10000
    
    s1 = C * z1;
    u1 = -(C*Bz)^-1*(C*Az*z1 + k*sign(s1));

    %
    Z1 = [Z1 z1];
    X1 = [X1 x1];
    S1 = [S1 s1];
    U1 = [U1 u1];
    
    z1 = z1 + (Az * z1 + Bz * u1) * ts;
    
    x1 = x1 + fx(x1, u1) * ts; 
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(Z1(i,:)', 'DisplayName', "A1")
    grid on;
    legend()
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(X1(i,:)', 'DisplayName', "A1")
    grid on;
    legend()
end

figure();
for i = 1:m
    subplot(m, 1, i), hold on;
    plot(U1(i,:)', 'DisplayName', "A1")
    grid on;
    legend()
end

figure();
for i = 1:n-m
    subplot(n-m, 1, i), hold on;
    plot(S1(i,:)', 'DisplayName', "A1")
    grid on;
    legend()
end
