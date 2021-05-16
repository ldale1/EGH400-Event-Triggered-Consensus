%
% Sliding for two agents, with fixed operating points
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
      
map = containers.Map;
targets = 128;
round_targets = (-(2*pi/targets):(2*pi/targets):(2*pi)) + pi/targets;

for target = round_targets
    x = [0; 0; 0; 0; target; 0];
    u = [0; 0; 0];

    A = Af(x, u);
    B = Bf(x, u);

    [Tr1, Temp] = qr(B);
    Tr1f = Tr1';
    T = [Tr1f(m+1:n,:);Tr1f(1:m,:)];

    Az = T * A * (T');
    A11 = Az(1:n-m, 1:n-m);
    A12 = Az(1:n-m, n-m+1:end);
    A21 = Az(n-m+1:end, 1:n-m);
    A22 = Az(n-m+1:end, n-m+1:end);

    Bz = T * B;
    B2 = Bz(n-m+1:end, :);

    %C1 = place(A11, A12, -2:-1:-4);
    C1 = lqr(A11, A12, 1, 1);
    C = [C1, eye(n-m)];
    
    regime.t = target;
    regime.Az = Az;
    regime.Bz = Bz;
    regime.C = C;
    regime.T = T;
    
    map(""+target) = regime;
end

%%

%{
roundTargets = [0 2.7 8 11.1];
v = 1;
vRounded = interp1(roundTargets,roundTargets,v,'nearest')
%}


ts = 0.01;

k = 3;

x1 = [3; 2; -1; -4; -pi/10; -0.5];
x2 = [1; 3; 1; 2; +pi/10; 2];

x1 = [3; 2; -1; -4; -5*pi/10; -2];
x2 = [1; 3; 1; 2; +5*pi/10; -2];


x1 = X0(:,1)
x2 = X0(:,2)
x3 = X0(:,3)


v = mod(x1(5), 2*pi);
vr = interp1(round_targets,round_targets,v,'nearest');   
r1 = map(""+vr);

v = mod(x2(5), 2*pi);
vr = interp1(round_targets,round_targets,v,'nearest');   
r2 = map(""+vr);

v = mod(x3(5), 2*pi);
vr = interp1(round_targets,round_targets,v,'nearest');   
r3 = map(""+vr);

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


for i = 1:1000
    z1d = 0.3333 * r1.T * (2*x1 - x2 - x3);
    z2d = 0.3333 * r2.T * (2*x2 - x1 - x3);
    z3d = 0.3333 * r3.T * (2*x3 - x1 - x2);
    
    
    v = mod(x1(5), 2*pi);
    vr = interp1(round_targets,round_targets,v,'nearest');   
    r1 = map(""+vr);
    
    v = mod(x2(5), 2*pi);
    vr = interp1(round_targets,round_targets,v,'nearest');   
    r2 = map(""+vr);
    
    v = mod(x3(5), 2*pi);
    vr = interp1(round_targets,round_targets,v,'nearest');   
    r3 = map(""+vr);
    
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