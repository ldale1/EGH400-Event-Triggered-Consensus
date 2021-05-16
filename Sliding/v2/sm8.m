%
% Sliding for two agents, with adaptation
%

close all;

n = 6;
m = 3;

fx = @(x, u) [...
    x(2); ...
    (u(1) + u(2))*cos(x(5)) - u(3)*sin(x(5)) - x(2); ...
    x(4); ...
    (u(1) + u(2))*sin(x(5)) + u(3)*cos(x(5)) - x(4); ...
    x(6); ...
    u(1) - u(2) - x(6)];

ts = 1/1e2;
k = 1



x1 = [3; 2; -1; -4; -5*pi/10; -2];
x2 = [1; 3; 1; 2; +5*pi/10; -2];
x3 = [-1; -3; 0; 2; +3*pi/10; 2];

x1 = X0(:,1)
x2 = X0(:,2)
x3 = X0(:,3)


u1 = zeros(3, 1);
u2 = zeros(3, 1);
u3 = zeros(3, 1);

r1 = get_regime(x1, u1);
r2 = get_regime(x2, u2);
r3 = get_regime(x3, u3);

z1 = r1.T * x1;
z2 = r2.T * x2;
z3 = r3.T * x3;

X1 = [];
X2 = [];
X3 = [];

Z1 = [];
Z2 = [];
Z3 = [];

S1 = [];
S2 = [];
S3 = [];

U1 = [];
U2 = [];
U3 = [];

for i = 1:10000
    %z1d = z1 - z2;
    %z2d = z2 - z1;
    
    z1d = r1.T * (2*x1 - x2 - x3);
    z2d = r2.T * (2*x2 - x1 - x3);
    z3d = r3.T * (2*x3 - x1 - x2);
   
    r1 = get_regime(x1, u1);
    r2 = get_regime(x2, u2);
    r3 = get_regime(x3, u3);
    
    s1 = r1.C * z1d;
    u1 = -(r1.C*r1.Bz)^-1*(r1.C*r1.Az*z1d + k*sign(s1));
    
    s2 = r2.C * z2d;
    u2 = -(r2.C*r2.Bz)^-1*(r2.C*r2.Az*z2d + k*sign(s2));
    
    s3 = r3.C * z3d;
    u3 = -(r3.C*r3.Bz)^-1*(r3.C*r3.Az*z3d + k*sign(s3));
    
    %
    X1 = [X1 x1];
    Z1 = [Z1 z1];
    S1 = [S1 s1];
    U1 = [U1 u1];
    
    X2 = [X2 x2];
    Z2 = [Z2 z2];
    S2 = [S2 s2];
    U2 = [U2 u2];
    
    X3 = [X3 x3];
    Z3 = [Z3 z3];
    S3 = [S3 s3];
    U3 = [U3 u3];
    
    x1 = x1 + fx(x1, u1) * ts;
    x2 = x2 + fx(x2, u2) * ts;
    x3 = x3 + fx(x3, u3) * ts;
    
    x1 = x1 + ts*[0.1 0 0.1 0 0 0]';
    x2 = x2 + ts*[0.1 0 0.1 0 0 0]';
    x3 = x3 + ts*[0.1 0 0.1 0 0 0]';
    
    z1 = z1 + (r1.Az * z1 + r1.Bz * u1) * ts;
    z2 = z2 + (r2.Az * z2 + r2.Bz * u2) * ts;
    z3 = z3 + (r3.Az * z3 + r3.Bz * u3) * ts;
end

figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(Z1(i,:)', 'DisplayName', "A1")
    plot(Z2(i,:)', 'DisplayName', "A2")
    plot(Z3(i,:)', 'DisplayName', "A3")
    grid on;
    legend()
end


figure();
for i = 1:n
    subplot(n, 1, i), hold on;
    plot(X1(i,:)', 'DisplayName', "A1")
    plot(X2(i,:)', 'DisplayName', "A2")
    plot(X3(i,:)', 'DisplayName', "A3")
    grid on;
    legend()
end

figure();
for i = 1:m
    subplot(m, 1, i), hold on;
    plot(U1(i,:)', 'DisplayName', "A1")
    plot(U2(i,:)', 'DisplayName', "A2")
    plot(U3(i,:)', 'DisplayName', "A3")
    grid on;
    legend()
end

figure();
for i = 1:n-m
    subplot(n-m, 1, i), hold on;
    plot(S1(i,:)', 'DisplayName', "A1")
    plot(S2(i,:)', 'DisplayName', "A2")
    plot(S3(i,:)', 'DisplayName', "A3")
    grid on;
    legend()
end