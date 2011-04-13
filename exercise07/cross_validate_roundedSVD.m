function [Kstar,tstar] = cross_validate_roundedSVD(X, X_gt)
%these are wrong dummy values, which you should find automatically by
%cross validation in this function

val_prec = 0.3;
[rows, columns] = size(X);

%1. split X and X_gt in training set and validation set
columnsize_val= round(columns*val_prec);
% Perform permutation
perm = randperm(columns);
% Splitting the data (columns only)
X_val = X(:,perm(1:columnsize_val));
X_train = X(:, perm(columnsize_val+1:columns));

X_gt_val = X_gt(:,perm(1:columnsize_val));
X_gt_train = X_gt(:, perm(columnsize_val+1:columns));
  
%2. for all K: get best t on training data
  %compute svd on training set
  [U,S,V] = svd(X_train,'econ');

  ts = zeros(length(S));
  for K = 1:size(S,2)
  %loop over possible K
    %take K components of decomposition
    Ustar = U(:,1:K); %all rows, 1 to i columns
    Sstar = S(1:K,1:K);
    Vstar = V(:,1:K); %all columns, 1 to i rows
    
    reconstructed = Ustar*Sstar*Vstar';
    
    %find rounding threshold t that best reconstructs the ground truth
    %matrix for the current value of K 
    
    tbest=0;
    terr=+Inf;
    for t=0: 0.01 :1
      err = sum(sum(abs((reconstructed > t) - X_gt_train)));
      if err < terr
        terr=err;
        tbest = t;
      end
    end
    ts(K) = tbest;
    
    
  end

      
%3. estimate Kstar from the validation set
  %compute svd of validation set
  [U,S,V] = svd(X_val,'econ');
  %validate which (K,t) pair to use from the training parameters
  kerr=+Inf;
  kbest=0;
  for K = 1:size(S,2)
  %loop over possible K
    %take K components of decomposition
    Ustar = U(:,1:K); %all rows, 1 to i columns
    Sstar = S(1:K,1:K);
    Vstar = V(:,1:K); %all columns, 1 to i rows
    
    reconstructed = Ustar*Sstar*Vstar';
    
    %find rounding threshold t that best reconstructs the ground truth
    %matrix for the current value of K 
   
    err = sum(sum(abs((reconstructed > ts(K)) - X_gt_val)));
    if err < kerr
        kerr=err;
        kbest = K;
    end
  end
  
%4. estimate tstar on the whole data set
  %do svd of whole data set
  %take the Kstar estimated in step 3
  %select tstar such that (Kstar, tstar) opimally reconstructs the ground
  %truth of the whole dataset
  
  tstar = ts(kbest);
  Kstar = kbest;

