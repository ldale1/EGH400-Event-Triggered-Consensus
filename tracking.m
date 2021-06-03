numstates = 2;
numinputs = 1;

m = 1;
b = 2;

A = [0 7; 9 -3];
B = [0; 1/m];
K = lqr(A, B, 1, 1); 



ts = 1/1e3;
t = 0:ts:1e4*ts;

Bg = [1; 0;];

x = [5; -2];
u = 0;

X = [];
G = [];

states = @(x, u) A*x + B*u;

for i = t
    
    g = sin(2*i);
    g_dot = 2*cos(2*i)/A(1,2);
    g_dot_dot = -2*2*sin(2*i)/A(1,2);
    
    x_bar = [g; g_dot];
    x_bar_dot = [g_dot; g_dot_dot];
    
    x_tilde = x - x_bar;

    u = -K*(x_tilde) - sin(i);
    
    % x = A\b FOR Ax=b
    Bu = -B*K*x_tilde - A*x_bar + x_bar_dot;
    u = B\Bu;
    
    x = x + states(x, u)*ts;% + (Bd*d)*ts;
    %x(1) = x(1) - 5*(rand()-0.5)*ts;
    
    X = [X x];
    G = [G Bg*g];
end

figure()
for i = 1:numstates
    subplot(numstates, 1, i), hold on;
    plot(t, X(i,:));
    plot(t, G(i,:), '--');
    grid on;
end


xlim([t(1) t(end)])






