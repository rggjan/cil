function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

% your collaborative filtering code here!
X_pred = X;

for i = 1:size(X, 1)
  row = X_pred(i, :);
  row(row == nil) = mean(row(row ~= nil));
  X_pred(i, :) = row;
end

X_pred(X_pred == nil) = mean(X_pred(X_pred ~= nil));
