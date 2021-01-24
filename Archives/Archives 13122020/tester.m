import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

A = [-2 2;
     -1 1];
B = [1;
     0];
C = eye(size(A));
D = zeros(size(B));
K = [1 -2];

[G, H] = c2d(A, B, 0.2); % Discrete time ss


ADJ = [0 0 0 1 1 1;
       1 0 0 0 0 0;
       1 1 0 1 0 0;
       1 0 0 0 0 0;
       0 0 0 1 0 1;
       0 0 0 0 1 0];
F = GraphFrobenius(ADJ);
F = [4 0 0 1 3 2;
     5 5 0 0 0 0;
     3 2 5 0 0 0;
     5 0 0 5 0 0;
     0 0 0 4 4 2;
     0 0 0 0 3 7]/10;
                 
DEG = diag(sum(ADJ, 2));
I = eye(size(ADJ, 1));

J = jordan(I - F);

dub = kron(I, G) + kron(J, -H*K);



sort(eig(dub(3:end, 3:end)))


%kron(eye(2:end, 2:end), G) + kron(, H *K)














%%


chairs = network.agents;

[~, ind] = sort([chairs.x], 2);
chairs_sorted = chairs(ind(1,:));









%%


a = [struct.empty(0)]
a = [a struct('a', 1)]
a = [a struct('a', 1)]



%%


a1 = network1.agents
a2 = network2.agents

for i = 1:length(a1)
    a1(i).X = a1(i).X - a2(i).X
end


network1.PlotStates