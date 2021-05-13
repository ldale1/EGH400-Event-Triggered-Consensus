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



p = 1;
c = 1.5;
K = [2, 5];

for sn = [[0, 0, 1, 1]; [0, 1, 0, 1]]
    sliding = sn(1);
    noise = sn(2);
    
    u = 0;
    U = u;

    x = [1; -2];
    X = x;

    for i = 1:10000
        
        if sliding
            s = [c, 1] * x;
            u = -c*x(2) - p*sign(s);
        else
            u = -K * x;
        end
        U = [U, u];

        
        if ~noise
            x = G * x + H*u;
        else
            x = G * x + H*(u + sin(2*i*ts));
        end
        X = [X, x];
    end
    
    figure();
    
    if sliding
        if ~noise
            sgtitle("Sliding Mode Control");
        else
            sgtitle("Sliding Mode Control With Noise");
        end
        
    else
        if ~noise
            sgtitle("State Feedback");
        else
            sgtitle("State Feedback with Noise");
        end
        
    end

    subplot(211); 
    hold on;
    plot(X(1,:), 'DisplayName', 'x_1');
    plot(X(2,:), 'DisplayName', 'x_2');
    legend('location', 'southeast');
    xlim([0, length(X)]);
    title('States')
    ylabel('Value');
    xlabel('Sample');
    grid on;
    
    subplot(212);
    plot(U);
    xlim([0, length(U)])
    title('Control Input')
    ylabel('Value');
    xlabel('Sample');
    grid on;
end

%{
for i = 1:10000
    u = -[1, 1] * x ;
    U = [U, u];
    
    x = G * x + H*(u + sin(2*i*ts));
    X = [X, x];
end
%}






