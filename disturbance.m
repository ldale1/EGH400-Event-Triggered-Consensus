A = [0 1; 2 3];
B = [0; 1];
Bd = [0; 1];
ts = 5/1e3;
t = 0:ts:1e4*ts;








K = lqrd(A, B, 1, 1, ts);

x = [10; -3];
X = [];

for i = t
    
    d = sin(i/5);
    
    u = -K*(x + d*ts);
    
    
    x = x + (A*x+B*u)*ts + (Bd*d)*ts;
    
    X = [X x];
end

figure()
plot(t, X')
grid on;
xlim([t(1) t(end)])