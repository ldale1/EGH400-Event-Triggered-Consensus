%set(groot,'defaultAxesXGrid','on')
%set(groot,'defaultAxesYGrid','on')
close all;

%{
x_1_dot = x_2
x_2_dot = u + f
f = sin(2t)


s = c.x_1 + x_2
u = -c.x_2 - p.sign(s)
%}

ts = 0.001;

A = [0 1; 0 0];
B = [0; 1];

[G, H] = c2d(A, B, ts);



p = 3;
c = 1.5;
K = [2, 5];

for sn = [[1]; [1]]%[[0, 0, 1, 1]; [0, 1, 0, 1]]
    sliding = sn(1);
    noise = sn(2);
    
    u1 = 0;
    U1 = u1;
    
    u2 = 0;
    U2 = u2;
    
    u3 = 0;
    U3 = u3;

    x1 = [-2; -5];
    X1 = x1;
    
    x2 = [-1; -3];
    X2 = x2;

    for i = 1:20000
        if sliding
            z1 = (x1 - x2);
            z1(2) = x1(2) - 2;
            s1 = [c, 1] * (z1);
            
            z2 = (x2 - x1);
            z2(2) = x2(2) - 2;
            s2 = [c, 1] * (z2);
            
            u1 = -c*(z1(2)) - p*sign(s1); %-c*(z1(2)) - p*sign(s1);
            u2 = -c*(z2(2)) - p*sign(s2); %-c*(z2(2)) - p*sign(s2);
        else
            u1 = -K * x1;
            u2 = -K * x2;
        end
        U1 = [U1, u1];
        U2 = [U2, u2];

        if noise
            x1 = G * x1 + H*(u1 + sin(2*i*ts));
            x2 = G * x2 + H*(u2 + sin(2*i*ts));
        else
            x1 = G * x1 + H*u1;
            x2 = G * x2 + H*u2;
        end
        
        X1 = [X1, x1];
        X2 = [X2, x2];
    end
    
    figure();

    subplot(311);
    hold on;
    plot(X1(1,:), 'DisplayName', 'x_1 A1');
    plot(X2(1,:), 'DisplayName', 'x_1 A2');
    legend('location', 'southeast');
    xlim([0, length(X1)]);
    
    subplot(312);
    hold on;
    plot(X1(2,:), 'DisplayName', 'x_2 A1');
    plot(X2(2,:), 'DisplayName', 'x_2 A2');
    legend('location', 'southeast');
    xlim([0, length(X1)]);

    subplot(313);
    hold on;
    plot(U1);
    plot(U2);
    xlim([0, length(U1)])
end

%{
for i = 1:10000
    u = -[1, 1] * x ;
    U = [U, u];
    
    x = G * x + H*(u + sin(2*i*ts));
    X = [X, x];
end
%}






