addpath data_gen
addpath submission-stubs
data_pairdist

%P = ([1, 2; 3, 4; 5, 6]);
%Q = ([8, 7; -3, 2; 2, 2; 2, -8]);

tic
pairdist(P, Q);
toc
