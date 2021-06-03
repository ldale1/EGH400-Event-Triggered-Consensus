numstates = 6;
numinputs = 3;
states = @(x, u) [...
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
 

Q = [zeros(1,numstates-6) 3 zeros(1,numstates-1);
     zeros(1,numstates-5) 1 zeros(1,numstates-2);
     zeros(1,numstates-4) 3 zeros(1,numstates-3);
     zeros(1,numstates-3) 1 zeros(1,numstates-4);
     zeros(1,numstates-2) 1 zeros(1,numstates-5);
     zeros(1,numstates-1) 3 zeros(1,numstates-6)];
R = 1;


ts = 5/1e3;
t = 0:ts:1e4*ts;

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
u = zeros(numinputs,1);

X = [];
D = [];

for i = t
    
    d = abs(sign(sin(i/5)));
    A = Af(x, u);
    B = Bf(x, u);
    
    K = lqr(A, B, Q, R);
    u = -K*(x + -Bd*d);
    
    x = x + states(x, u)*ts;% + (Bd*d)*ts;
    
    X = [X x];
    D = [D Bd*d];
end

figure()
for i = 1:numstates
    subplot(6, 1, i), hold on;
    plot(t, X(i,:));
    plot(t, D(i,:), '--');
    grid on;
end


xlim([t(1) t(end)])
















function v = not0(v)
    if v==0
        v = 0.001;
    end
end

function s = sin0(rad)
    s = sin(rad);
    if s==0
        s = 0.001;
    end
end

function c = cos0(rad)
    c = cos(rad);
    if c==0
        c = -0.001;
    end
end
