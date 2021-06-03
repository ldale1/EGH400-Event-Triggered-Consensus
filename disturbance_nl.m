% The agent dynamics
run('+ConsensusMAS/Models/NonLinear/QuadrotorTest')
run('+ConsensusMAS/Models/NonLinear/HoverCraft')
Q = controller_struct.Q;
R = controller_struct.R;

%%
 


ts = 1/1e3;
N = 1e4;
t = linspace(0, ts*N, N);

Bd = [1; 0; 0; 0; 0; 0];


scale_p = 1;
scale_p_dot = 1;
scale_theta = pi/8;
scale_theta_dot = 0.2;

x_generator = @() [ ...
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    scale_p*(rand()-1/2); 
    scale_p_dot*(rand()-1/2); 
    1/4;
    scale_theta_dot*(rand()-1/2)];


x = x_generator();
z = x;
u = zeros(numinputs,1);

X = [];
Z = [];
D = [];
T = [];

for i = t
    
    d = abs(sign(sin(i/5)));
    A = Af(x, u);
    B = Bf(x, u);
    
    [G, H] = c2d(A, B, ts);
    
    
    try
        K = lqrd(A, B, Q, R, ts);
        u = -K*x;% + -Bd*d);
    catch
        u = -ones(3,6)*x
    end
    
    x = x + states(x, u)*ts;% + (Bd*d)*ts;
    z = G*z + H*u;
    
    X = [X x];
    Z = [Z z];
    D = [D Bd*d];
    T = [T i];
end

figure()
for i = 1:numstates
    subplot(numstates, 1, i), hold on;
    
    state_nl = X(i,:);
    state_l = Z(i,:);
    plot(T, state_nl);
    plot(T, state_l, '--');
    grid on;
    
    t0 = 0;
    tend = min(10, T(end));
    i0 = t0/ts+1;
    iend = tend/ts;
    
    
    upper = max(max(state_nl(i0:iend)), max(state_l(i0:iend)));
    lower = min(min(state_nl(i0:iend)), min(state_l(i0:iend)));
    
    xlim([t0 tend]);
    ylim([lower upper]);
end


















function v = not0(v)
    if v==0
        %v = 0.0001;
    end
end

function s = sin0(rad)
    s = sin(rad);
    if s==0
        %s = 0.0001;
    end
end

function c = cos0(rad)
    c = cos(rad);
    if c==0
        %c = -0.0001;
    end
end
