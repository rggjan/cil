function results = Evaluate_RBAC_roundedSVD()

results = struct();

%% load the data
load('X.mat');
load('GTruth.mat');
X_gt = double((GTruth.U*GTruth.Z)>0);

%% visualize data
errors = [];
Ks = [];
ts = [];
for i=1:11
    
    %randomly split into training set and test set
    randInd = randperm(size(X,2));
    X_gt = X_gt(:,randInd);
    X = X(:,randInd);
    
    splitIndexStep = round(size(X,2)/2);
    testInd = 1:splitIndexStep;
    trainInd = splitIndexStep+1:size(X,2);
    X_train = X(:,trainInd);
    X_test = X(:,testInd);
    X_train_gt = X_gt(:,trainInd);
    X_test_gt = X_gt(:,testInd);
    figure(1);    
    title('Noisy Test Data')
    
    figure(2);
    imbin(X_test_gt);
    title('Noisefree Test Data')
    
    %get estimated parameters K and t
    [K,t] = cross_validate_roundedSVD(X_train, X_train_gt);
    Ks = [Ks;K];
    ts = [ts;t];
    
    %use K and t to reconstruct the test data matrix
    [U_tilde,S_tilde,V_tilde] = svd(X_test);
    
    U = U_tilde(:, 1:K);
    S = S_tilde(1:K, 1:K);
    V = V_tilde(:, 1:K);
    
    X_hat = U*S*V';
    
    roundedX = double(X_hat>t);
    
    figure(3);
    imbin(roundedX);
    title('Denoised Test Data')
    
    %obtain reconstruction error (compare against ground truth)
    err = sum(sum(abs(X_test_gt-roundedX)))./numel(X_test);
    errors = [errors; err];
end

results.ranking.medianError = median(errors);
results.ranking.stdDeviation = std(errors);
results.errors = errors;
results.K = Ks;
results.t = ts;

end


