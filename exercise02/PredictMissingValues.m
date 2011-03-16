function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

% your collaborative filtering code here!

column_pred = zeros(size(X));
row_pred = zeros(size(X));

for i = 1:size(X, 1)
  row = X(i, :);
  row(row == nil) = mean(row(row ~= nil));
  row_pred(i, :) = row;
end

for i = 1:size(X, 2)
  column = X(:, i);
  column(column == nil) = mean(column(column ~= nil));
  column_pred(:, i) = column;
end

X_average = X;
average = (column_pred + 2*row_pred)/3;
X_average(X_average == nil) = average(X_average == nil);

pause
size(X_average)
[U, D, V] = svd(X_average);
pause

U = U*sqrt(D);
V = sqrt(D)*V;

U = U(:, 1:10);
V = V(1:10, :);

prediction = U*V;

X_pred = X;
X_pred(X_pred == nil) = prediction(X_pred == nil);
