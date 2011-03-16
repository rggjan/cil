function Y = stdize(X)
  len = size(X, 1);
  Y = (X - repmat(mean(X), len, 1)) ./ repmat(std(X), len, 1);
end
