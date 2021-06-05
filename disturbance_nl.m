% The agent dynamics
run('+ConsensusMAS/Models/NonLinear/QuadrotorTest')
%run('+ConsensusMAS/Models/NonLinear/HoverCraft')
Q = controller_struct.Q;
R = controller_struct.R;

%%
 




Bd = [1; 0; 0; 0; 0; 0];

scale_p = 10;
scale_p_dot = 0;
scale_theta = pi/8;
scale_theta_dot = 0.2;

x_generator = @() [ ...
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    pi/4*(1+0.2*(rand()-0.5));
    scale_theta_dot*(rand()-1/2)];


x0 = x_generator();

%%

ts = 1/1e2;
N = 5e4;
t = linspace(0, ts*N, N);

x=x0;
z = x;
u = zeros(numinputs,1);

X = [];
Z = [];
D = [];
T = [];
U = [];

for i = t
    
    %d = abs(sign(sin(i/5)));
    A = Af(x, u);
    B = Bf(x, u);
    
    [G, H] = c2d(A, B, ts);
    
    K = lqrd(A, B, 1, 10, ts);
    u = -K*33*(x .* [1; 1; 1; 1; 20; 1]);% + -Bd*d);

    x = x + states(x, u)*ts;% + (Bd*d)*ts;
    z = G*z + H*u;
    
    X = [X x];
    Z = [Z z];
    %D = [D Bd*d];
    T = [T i];
    U = [U u];
end

%{
figure()
for i = 1:numinputs
    subplot(numinputs, 1, i), hold on;
    
    %state_l = Z(i,:);
    plot(T, U(i,:));
    %plot(T, state_l, '--');
    grid on;

end
%}

figure()
for i = 1:numstates
    subplot(numstates, 1, i), hold on;
    
    state_nl = X(i,:);
    %state_l = Z(i,:);
    plot(T, state_nl);
    %plot(T, state_l, '--');
    grid on;
    
    %{
    t0 = 0;
    i0 = t0/ts+1;
    
    tend = min(10, T(end));
    iend = tend/ts;
    
    upper = max(max(state_nl(i0:iend)), max(state_l(i0:iend)));
    lower = min(min(state_nl(i0:iend)), min(state_l(i0:iend)));
    
    xlim([t0 tend]);
    ylim([lower upper]);
    %}
end