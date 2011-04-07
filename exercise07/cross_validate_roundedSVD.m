function [Kstar,tstar] = cross_validate_roundedSVD(X, X_gt)
%these are wrong dummy values, which you should find automatically by
%cross validation in this function
  Kstar = 10;
  tstar = 0.5;


%1. split X and X_gt in training set and validation set  
  
%2. for all K: get best t on training data
  %compute svd on training set
  %loop over possible K
    %take K components of decomposition
    %find rounding threshold t that best reconstructs the ground truth
    %matrix for the current value of K 
      
%3. estimate Kstar from the validation set
  %compute svd of validation set
  %validate which (K,t) pair to use from the training parameters  
  
%4. estimate tstar on the whole data set
  %do svd of whole data set
  %take the Kstar estimated in step 3
  %select tstar such that (Kstar, tstar) opimally reconstructs the ground
  %truth of the whole dataset

