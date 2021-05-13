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

ts = 0.0001;

A = [0 1; 0 0];
B = [0; 1];

[G, H] = c2d(A, B, ts);

X = @(x, u, t) G*x + H*u;
Xn = @(x, u, t) G*x + H*u + H*sin(2*t*ts);

p = 5;
c = 1.5;
K = [2, 5];

for sn = 1%[[1 0];]% [1 1]]%[[0, 0, 1, 1]; [0, 1, 0, 1]]
    sliding = 1;%sn(1);
    noise = 0;%sn(2);
    
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
    
    x3 = [3; 6];
    X3 = x3;

    for i = 1:50000
        z1 = (x1 - x2) + (x1 - x3);
        z2 = (x2 - x1) + (x2 - x3);
        z3 = (x3 - x1) + (x3 - x2);
        
        %z1(2) = x1(2) - 1;
        
        %z2(1) = z2(1) - 9;
        %z2(2) = x2(2) - 1;
            
        %z3(1) = z3(1) + 9;
        %z3(2) = x3(2) - 1;
            
        if sliding
            
            s1 = [c, 1] * (z1);        
            s2 = [c, 1] * (z2);
            s3 = [c, 1] * (z3);
            
            u1 = -c*(z1(2)) - p*sign(s1);
            u2 = -c*(z2(2)) - p*sign(s2);
            u3 = -c*(z3(2)) - p*sign(s3);
        else
            u1 = -K * z1;
            u2 = -K * z2;
            u3 = -K * z3;
        end
        U1 = [U1, u1];
        U2 = [U2, u2];
        U3 = [U3, u3];

        if noise
            x1 = X(x1, u1, i);%G * x1 + H*(u1 + sin(2*i*ts));
            x2 = X(x2, u2, i);%G * x2 + H*(u2 + sin(2*i*ts));
            x3 = X(x3, u3, i);%G * x3 + H*(u3 + sin(2*i*ts));
            
            np = 3;
            gwn = @(np) np*(sin(2*i*ts));
            
            x1(2) = x1(2) + gwn(np)*ts;
            x2(2) = x2(2) + gwn(np)*ts;
            x3(2) = x3(2) + gwn(np)*ts;
        else
            x1 = G * x1 + H*u1;
            x2 = G * x2 + H*u2;
            x3 = G * x3 + H*u3;
        end
        
        X1 = [X1, x1];
        X2 = [X2, x2];
        X3 = [X3, x3];
    end
    
    figure();

    subplot(311);
    hold on;
    plot(X1(1,:), 'DisplayName', 'x_1 A1');
    plot(X2(1,:), 'DisplayName', 'x_1 A2');
    plot(X3(1,:), 'DisplayName', 'x_1 A3');
    legend('location', 'southeast');
    xlim([0, length(X1)]);
    
    subplot(312);
    hold on;
    plot(X1(2,:), 'DisplayName', 'x_2 A1');
    plot(X2(2,:), 'DisplayName', 'x_2 A2');
    plot(X3(2,:), 'DisplayName', 'x_2 A3');
    legend('location', 'southeast');
    xlim([0, length(X1)]);

    subplot(313);
    hold on;
    plot(U1);
    plot(U2);
    plot(U3);
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






