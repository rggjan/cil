function D = pairdist(Q, P)
  [X, Y] = meshgrid(P(:, 1), Q(:, 1));
  xs = X - Y;
  [X, Y] = meshgrid(P(:, 2), Q(:, 2));
  ys = X - Y;

  D = sqrt(xs.^2+ys.^2);
end
