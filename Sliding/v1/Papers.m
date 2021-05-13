% https://link.springer.com/content/pdf/10.1007%2F978-0-8176-4893-0_2.pdf

A = [1 1 1;
    0 1 3;
    1 0 1];
B = [0 1;
    1 -1;
    -1 0];

Tr = [sqrt(3)/3, sqrt(3)/3, sqrt(3)/3;
    sqrt(6)/3, -sqrt(6)/6, -sqrt(6)/6;
    0, sqrt(2)/2, -sqrt(2)/2];

Tr * B
