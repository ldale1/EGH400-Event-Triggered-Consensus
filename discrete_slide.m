% The agent dynamics
run('+ConsensusMAS/Models/NonLinear/QuadrotorTest')
%run('+ConsensusMAS/Models/NonLinear/HoverCraft')
Q = controller_struct.Q;
R = controller_struct.R;

%%

scale_p = 50;
scale_p_dot = 4;
scale_theta = pi;
scale_theta_dot = 3;

x_generator = @() [ ...
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_theta*(1+0.2*(rand()-0.5));
    scale_theta_dot*(rand()-1/2)];

x10 = x_generator();
x20 = x_generator();
x30 = x_generator();
x40 = x_generator();

%%
clc

global ts
ts = 1/1e3;
N = 1e4;
t = linspace(0, ts*N, N);

x1 = x10;
z1 = x1;
u1 = zeros(numinputs,1);

x2 = x20;
z2 = x2;
u2 = zeros(numinputs,1);

x3 = x30;
z3 = x3;
u3 = zeros(numinputs,1);

x4 = x40;
z4 = x4;
u4 = zeros(numinputs,1);

X1 = [];
Z1 = [];
U1 = [];

X2 = [];
Z2 = [];
U2 = [];

X3 = [];
Z3 = [];
U3 = [];

X4 = [];
Z4 = [];
U4 = [];

D = [];
T = [];



%{
tau = ts;
lambda = 0.5/ts;
vee = 0.5/ts;
lambda_tau = lambda * tau;
v_tau = vee * tau;
assert(1-lambda*tau>0, "BAD")

get_u = @(R, x) -(R.C*R.Bz)^-1*(R.C*R.Az*(R.Tr*x) - (1-lambda_tau)*R.C*(R.Tr*x) + v_tau*sign(R.C*(R.Tr*x)));
obj.controller = @(x, u, z) get_u(smc_regime(Af(x, u), Bf(x, u)), z);
%}




k = 1;
q = 0.5;
h = 0.5;
qh = q*h;

get_u = @(R, x) -(R.C*R.Bz)^-1*(R.C*R.Az*(R.Tr*x) + (1-qh)*R.C*(R.Tr*x) + h*k*sign(R.C*(R.Tr*x)));
obj.controller = @(x, u, z) get_u(smc_regime(Af(x, u), Bf(x, u)), z);


for i = t
    %d = abs(sign(sin(i/5)));
    %A1 = Af(x1, u1);
    %B1 = Bf(x1, u1);
    
    %[G1, H1] = c2d(A1, B1, ts);
    
    %K1 = lqrd(A1, B1, 1, 1, ts);
    
    backtrack = 11;
    
    u1_count = length(U1);
    u1_prev = U1(:,max(u1_count-backtrack, 1):end);
    if (length(u1_prev) < backtrack + 1)
        u1_mean = u1;
    else
        u1_mean = u1;
        for ii = 1:numinputs
            u1_mean(ii) = rms(interp1(1:length(u1_prev), u1_prev(ii,:), 1:1/6:length(u1_prev)));
        end
        u1_mean = mean(u1_prev, 2);
    end
    
    u2_count = length(U2);
    u2_prev = U2(:,max(u2_count-backtrack, 1):end);
    if (length(u2_prev) < backtrack + 1)
        u2_mean = u1;
    else
        u2_mean = u1;
        for ii = 1:numinputs
            u2_mean(ii) = rms(interp1(1:length(u2_prev), u2_prev(ii,:), 1:1/6:length(u2_prev)));
        end
        u2_mean = mean(u2_prev, 2);
    end
    
    u3_count = length(U3);
    u3_prev = U3(:,max(u3_count-backtrack, 1):end);
    if (length(u3_prev) < backtrack + 1)
        u3_mean = u1;
    else
        u3_mean = u1;
        for ii = 1:numinputs
            u3_mean(ii) = rms(interp1(1:length(u3_prev), u3_prev(ii,:), 1:1/6:length(u3_prev)));
        end
        u3_mean = mean(u3_prev, 2);
    end
    
    u4_count = length(U4);
    u4_prev = U4(:,max(u4_count-backtrack, 1):end);
    if (length(u4_prev) < backtrack + 1)
        u4_mean = u1;
    else
        u4_mean = u1;
        for ii = 1:numinputs
            u4_mean(ii) = rms(interp1(1:length(u4_prev), u4_prev(ii,:), 1:1/6:length(u4_prev)));
        end
        u4_mean = mean(u4_prev, 2);
    end
    
    
    
    
    z1 = 0.25*((x1 - x2) + (x1 - x3) + (x1 - x4));
    z1(2) = z1(2)*4/5 + (x1(2) - -10)/5;
    %z1(4) = z1(4)*4/5 + (x1(4) - +10)/5;
    %z1(5) = z1(5)*4/5 + (x1(5) - +pi/8)/5;
    z1(6) = x1(6);
    
    u1 = obj.controller(x1, u1_mean, z1); %K*33*(x .* [1; 1; 1; 1; 20; 1]);% + -Bd*d);
    
    
    z2 = 0.25*((x2 - x1) + (x2 - x3) + (x2 - x4));
    z2(2) = z2(2)*4/5 + (x2(2) - -10)/5;
    %z2(4) = z2(4)*4/5 + (x2(4) - +10)/5;
    %z2(5) = z2(5)*4/5 + (x2(5) - +pi/8)/5;
    z2(6) = x2(6);
    
    u2 = obj.controller(x2, u2_mean, z2); %K*33*(x .* [1; 1; 1; 1; 20; 1]);% + -Bd*d);
    
    
    z3 = 0.25*((x3 - x1) + (x3 - x2) + (x3 - x4));
    z3(2) = z3(2)*4/5 + (x3(2) - -10)/5;
    %z3(4) = z3(4)*4/5 + (x3(4) - +10)/5;
    %z3(5) = z3(5)*4/5 + (x3(5) - +pi/8)/5;
    z3(6) = x3(6);
    
    u3 = obj.controller(x3, u3_mean, z3); %K*33*(x .* [1; 1; 1; 1; 20; 1]);% + -Bd*d);
    
    
    z4 = 0.25*((x4 - x1) + (x4 - x2) + (x4 - x3));
    z4(2) = z4(2)*4/5 + (x4(2) - -10)/5;
    %z4(4) = z4(4)*4/5 + (x4(4) - +10)/5;
    %z4(5) = z4(5)*4/5 + (x4(5) - +pi/8)/5;
    z4(6) = x4(6);
    
    u4 = obj.controller(x4, u4_mean, z4); %K*33*(x .* [1; 1; 1; 1; 20; 1]);% + -Bd*d);
    
    
    
    
    x1 = x1 + states(x1, u1)*ts;% + (Bd*d)*ts;
    x2 = x2 + states(x2, u2)*ts;% + (Bd*d)*ts;
    x3 = x3 + states(x3, u3)*ts;% + (Bd*d)*ts;
    x4 = x4 + states(x4, u4)*ts;% + (Bd*d)*ts;
    
    Bd = 1*[sin(i); 0; 0; 0; 0; 0];
    x1 = x1 + Bd*ts;
    x2 = x2 + Bd*ts;
    x3 = x3 + Bd*ts;
    x4 = x4 + Bd*ts;
    
    
    
    X1 = [X1 x1];
    U1 = [U1 u1];
    
    X2 = [X2 x2];
    U2 = [U2 u2];
    
    X3 = [X3 x3];
    U3 = [U3 u3];
    
    X4 = [X4 x4];
    U4 = [U4 u4];
    
    T = [T i];
end

figure()
for i = 1:numinputs
    subplot(numinputs, 1, i), hold on;
    plot(T, U1(i,:));
    plot(T, U2(i,:));
    plot(T, U3(i,:));
    plot(T, U4(i,:));
    
    grid on;
end


figure()
for i = 1:numstates
    subplot(numstates, 1, i), hold on;
    plot(T, X1(i,:));
    plot(T, X2(i,:));
    plot(T, X3(i,:));
    plot(T, X4(i,:));
    grid on;
end



%%

function reg = smc_regime(A, B)
    global ts
    %{
    get_Tr = @(A, B, Tr, m, n)    

    get_Az = @(A, Tr) Tr * A * (Tr');
    get_Bz = @(B, Tr) Tr * B;

    get_C = @(Az, m, n) [lqr(Az(1:n-m, 1:n-m), Az(1:n-m, n-m+1:end), 1, 1), eye(m)];

    get_regime = @(A, B, ) [...
        get_Az(A, Tr), ...
        get_Bz(B, Tr), ...
        get_C(), ...
        Tr]; 
    %}
    [n,m] = size(B);

    [Trp, ~] = qr(B);
    Tr = Trp';
    Tr = [Tr(m+1:n,:);Tr(1:m,:)];

    Az = Tr * A * (Tr');
    Bz = Tr * B;
    
    %Q = eye(4).*[1 1 1 1];
    Q = 1;
    R = 1;
    
    A11 = Az(1:n-m, 1:n-m);
    A12 = Az(1:n-m, n-m+1:end);
    
    C = [lqrd(A11, A12, Q, R, ts), eye(m)];
    
    [Az, Bz] = c2d(Az, Bz, ts);


    reg.Az = Az;
    reg.Bz = Bz;
    reg.C = C;
    reg.Tr = Tr;
    %reg = {Az, Bz, C, Tr};      
end


