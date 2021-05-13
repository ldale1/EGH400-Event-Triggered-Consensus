load place

n = 6;
m = 3;

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
      
map = containers.Map;
targets = 128;
round_targets = (-(2*pi/targets):(2*pi/targets):(2*pi));% + pi/targets;

for target = round_targets
    x = [0; 0; 0; 0; target; 0];
    u = [0; 0; 0];

    A = Af(x, u);
    B = Bf(x, u);

    [Tr1, Temp] = qr(B);
    Tr1f = Tr1';
    T = [Tr1f(m+1:n,:);Tr1f(1:m,:)];

    Az = T * A * (T');
    A11 = Az(1:n-m, 1:n-m);
    A12 = Az(1:n-m, n-m+1:end);
    A21 = Az(n-m+1:end, 1:n-m);
    A22 = Az(n-m+1:end, n-m+1:end);

    Bz = T * B;
    B2 = Bz(n-m+1:end, :);

    %C1 = place(A11, A12, -2:-1:-4);
    C1 = lqr(A11, A12, 1, 1);
    C = [C1, eye(n-m)];
    
    regime.t = target;
    regime.Az = Az;
    regime.Bz = Bz;
    regime.C = C;
    regime.T = T;
    
    map(""+target) = regime;
end

%% Plot it

mapv = map.values;
figure();
for m = 1:length(mapv)
    mapvi = cell2mat(mapv(m));
    
    %C(:,:,m) = mapvi.C;
    %t(m) = mapvi.t;
    
    t = mapvi.t;
    C = mapvi.C;
    
    for i = 1:3
        for j = 1:3
            subplot(3, 3, (i-1)*3 + j); hold on;
            stem(t, C(i, j), 'o');
        end
    end
end

tags = 4
xts = [0]
xtlabels = [{'0'}]
for i = 1:tags
    xts = [xts  (i/tags)*(2*pi)];
    xtlabels = [xtlabels {sprintf('%d\\pi/%d', i * 2, tags)}];
end

for i = 1:3
    for j = 1:3
        subplot(3, 3, (i-1)*3 + j); grid on;
        xticks(xts);
        xticklabels(xtlabels);
    end
end

