%
% Basic testing
%


%% Example

A = [1 5 0; -1 2 0; 2 0 1];
B = [1 1; 0 1; 1 1];
C = [1 0 1; 0 1 0];
T = [1 0 -1; 0 -1 1; 0 1 0];

n = 3;
m = 2;

Az = T * A * (T');
A11 = Az(1,1)
A12 = Az(1, 2:3)
A21 = Az(2:3, 1)
A22 = Az(2:3, 2:3)

Bz = T * B;
B2 = Bz(2:3, :)

%C = [-0.1538 1 0; 0.2308 0 1];
C = [-0.1967 1 0; 0.1639 0 1];
% place(A11, A12, -2)
C1 = C(:,1)

ts = 0.001;

k = 0.8;


z1 = [3; 2; -1];
Z1 = z1;

s1 = C * z1;
S1 = s1;

u1 = -(C*Az*z1 + k*sign(s1));
u1 = -(C*Bz)^-1*(C*Az*z1 + k*sign(s1));
U1 = u1;

for i = 1:10000
    z1 = z1 + (Az * z1 + Bz * u1) * ts;
    s1 = C * z1;
    u1 = -(C*Az*z1 + k*sign(s1));
    u1 = -(C*Bz)^-1*(C*Az*z1 + k*sign(s1));

    
    Z1 = [Z1 z1];
    S1 = [S1 s1];
    U1 = [U1 u1];
end

%% Hovercraft

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


z1 = [3; 2; -1; -4; 1; 4];
Z1 = z1;

z2 = [3; 2; -1; -4; 1; 4] + 3;
Z2 = z1;

for i = 1:10000
    
    z1d = z1 - z2;
    z2d = z2 - z1;
    
    
    s1 = C * z1d;
    S1 = s1;
    u1 = -(C*Az*z1d + k*sign(s1));
    U1 = u1;

    s2 = C * z1d;
    S2 = s1;
    u2 = -(C*Az*z1d + k*sign(s1));
    U2 = u1;
    
    %
    Z1 = [Z1 z1];
    S1 = [S1 s1];
    U1 = [U1 u1];
    
    Z2 = [Z2 z2];
    S2 = [S2 s2];
    U2 = [U2 u2];
    
    z1 = z1 + (Az * z1 + Bz * u1) * ts;
    z2 = z2 + (Az * z2 + Bz * u1) * ts;
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(Z1(i,:)', 'DisplayName', "A1")
    plot(Z2(i,:)', 'DisplayName', "A2")
    legend()
end


figure();
for i = 1:m
    subplot(m, 1, i), hold on;
    plot(U1(i,:)', 'DisplayName', "A1")
    plot(U2(i,:)', 'DisplayName', "A2")
    legend()
end


%% Hovercraft (w/out velocity)

Af = @(x,u) [-1 0 (-(u(1)+u(2))*sin(x(3)) - u(3)*cos(x(3))) 0;
          0 -1 ((u(1)+u(2))*cos(x(3)) - u(3)*sin(x(3))) 0;
          0 0 0 1;
          0 0 0 -1];
Bf = @(x,u) [cos(x(3)) cos(x(3)) -sin(x(3));
          sin(x(3)) sin(x(3)) cos(x(3));
          0 0 0;
          1 -1 0];
      
x = [0; 0; pi/8; 0];
u1 = [0; 0; 0];

A = Af(x, u1)
B = Bf(x, u1)
      

[Tr1, Temp] = qr(B);
Tr1f = Tr1^-1;
T = [Tr1f(4,:),
    Tr1f(1,:),
    Tr1f(2,:),
    Tr1f(3,:)];

n = 4;
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
C1 = lqr(A11, A12, 1, 1)
C = [C1, eye(m)]

ts = 0.001;

k = 0.8;
z1 = [3; 2; -4; -1;];
Z1 = z1;

s1 = C * z1;
S1 = s1;

u1 = -(C*Az*z1 + k*sign(s1));
U1 = u1;

for i = 1:10000
    z1 = z1 + (Az * z1 + Bz * u1) * ts;
    s1 = C * z1;
    u1 = -(C*Bz)^-1*(C*Az*z1 + 10*k*sign(s1));
    
    Z1 = [Z1 z1];
    S1 = [S1 s1];
    U1 = [U1 u1];
end