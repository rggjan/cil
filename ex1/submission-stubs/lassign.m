function a = lassign_reference_vec(X, mu0, Sigma0, mu1, Sigma1)
  a = g(X, mu0, Sigma0) < g(X, mu1, Sigma1);
  a = a+1;
end

function p = g(X, mu, Sigma)
  D = (X - repmat(mu, 1, size(X, 2)))';
  p = -log(det(Sigma)) - sum((D/Sigma).*D,2)';
end
