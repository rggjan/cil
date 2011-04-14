function results = rbac_eval()

%load training data set
load X_1.mat
Nusers = size(X,2);

%split data into training and test set
randUsers = randperm(Nusers);
X_train = X(:,randUsers(1:round(Nusers/2)));
X_test = X(:,randUsers(round(Nusers/2)+1:end));

%train on training data
tic
[ Z, U ] = estimateRolesAndAssignments(X_train);    
runtime = toc;

%now test on test data
NrandRep = 10;
G = ones(1,NrandRep);
for i=1:NrandRep
    G(i) = generalizationError(X_test, U, Z, 0.7);
end
Gmedian = median(G);

results = struct();
results.genErrorFullStat = G;
results.ranking.genError = Gmedian;
results.ranking.runtime = runtime;

