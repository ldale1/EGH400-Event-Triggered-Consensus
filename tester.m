% The network
SIZE = size(ADJ,2);
ADJ = [0 0 0 1 1 1;
       1 0 0 0 0 0;
       1 1 0 1 0 0;
       1 0 0 0 0 0;
       0 0 0 2 0 1;
       0 0 0 0 1 0];
   
I = eye(SIZE);
DEG = diag(sum(ADJ, 2));
L = DEG - ADJ;
F = (I + DEG)^-1 * (I + ADJ)