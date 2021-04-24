% P > 0
% 0 > -P
% A'P + PA < 0

A = [0 1; -2 -3];

setlmis([])

P = lmivar(1, [size(A,1) 1]);


%LMI TERM
% lmiterm(termID, A, B, flag)
% termId 1x4
%   1st - which LMI is defined
%   2nd, 3rd - position of the term
%   4th which decision var
% A left multiplier
% B right multiplier
% flag 's' symmetrical
lmiterm([1 1 1 P], 1, A, 's');

lmiterm([1 1 2 0], 1);

lmiterm([1 2 2 P], -1, 1);

LMISYS = getlmis;

[tmin, Psol] = feasp(LMISYS);

P = dec2mat(LMISYS, Psol, P)



%%
A = [0 7; -1 1];
B = [2; 1];


A1 = A';
A2 = A;
A3 = -2*B*(B');

% X*A1 + A2*X + A3 < 0


setlmis([])

P = lmivar(1, [size(A,1) 1]);

% https://link.springer.com/content/pdf/bbm%3A978-3-319-32324-4%2F1.pdf

lmiterm([1 1 1 P], 1, A1);
lmiterm([1 1 1 P], A2, 1);
lmiterm([1 1 1 0], A3);

lmiterm([1 2 2 P], 1, 1);


%lmiterm([1 2 2 1], -1, 1);



LMISYS = getlmis;
[tmin, Psol] = feasp(LMISYS);
P = dec2mat(LMISYS, Psol, P)

P^-1

%P = [1.0728, −0.5126; 
%    −0.5126, 1.2662]




