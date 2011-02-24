addpath data_gen
addpath submission-stubs

data_stdize

%A = [1, 2, 3, 4; 4, 5, 5, 4; 8, 8.2, -2, 3]

tic
stdize(X);
toc
