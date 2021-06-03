numstates = 2;
numinputs = 1;

m = 1;
b = 2;

A = [0 1; 0 -b/m];
B = [0; 1/m];
K = lqr(A, B, 1, 1); 



ts = 5/1e2;
t = 0:ts:1e3*ts;

Bg = [1; 0;];

x = [.1; -.2];
u = 0;

X = [];
G = [];

states = @(x, u) A*x + B*u;

for i = t
    
    g = sin(i);
    g_dot = cos(i);
    x_bar = [g; g_dot];
    x_tilde = x - x_bar;

    u = -K*(x_tilde) + 2*cos(i) - sin(i);
    
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






