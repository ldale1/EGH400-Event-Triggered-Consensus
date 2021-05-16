function controller_smc = LoadController(A, B)


    map = containers.Map;
    targets = 128;
    round_targets = (-(2*pi/targets):(2*pi/targets):(2*pi)) + pi/targets;

    for target = round_targets
        x = [0; 0; 0; 0; target; 0];
        u = [0; 0; 0];

        An = A(x, u);
        Bn = B(x, u);

        [Tr1, Temp] = qr(Bn);
        Tr1f = Tr1';
        T = [Tr1f(m+1:n,:); Tr1f(1:m,:)];

        Az = T * An * (T');
        A11 = Az(1:n-m, 1:n-m);
        A12 = Az(1:n-m, n-m+1:end);
        %A21 = Az(n-m+1:end, 1:n-m);
        %A22 = Az(n-m+1:end, n-m+1:end);

        Bz = T * Bn;
        %B2 = Bz(n-m+1:end, :);

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
    
    myregime = @(x) map(""+interp1(round_targets, round_targets, mod(x(5), 2*pi), 'nearest'));
    
    -(r1.C*r1.Bz)^-1*(r1.C*r1.Az*z1d + k*sign(s1))
s = @(c, x) c * x;
u1 = @(c, Az, Bz, z); 

end