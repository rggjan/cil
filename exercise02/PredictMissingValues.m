function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

% your collaborative filtering code here!
X_pred = X;

column_pred = zeros(size(X));
row_pred = zeros(size(X));

for i = 1:size(X, 1)
  row = X_pred(i, :);
  row(row == nil) = mean(row(row ~= nil));
  row_pred(i, :) = row;
end

for i = 1:size(X, 2)
  column = X_pred(:, i);
  column(column == nil) = mean(column(column ~= nil));
  column_pred(:, i) = column;
end

average = (column_pred + 2*row_pred)/3;
X_pred(X_pred == nil) = average(X_pred == nil);
