function Z = sparseCoding(U, X, sigma, rc_min)
%
% Perform sparse coding using a modified matching pursuit tailored to the
% inpainting problem with residual stopping criterion.
%
% INPUT
% U: (d x l) unit norm atoms
% X: (d x n) observations
% sigma: residual error stopping criterion, normalized by signal norm
% rc_min: minimal residual correlation before stopping
%
% OUTPUT
% Z: MP coding
%

l = size(U,2);
n = size(X,2);

Z = zeros(l, n);

% Loop over all observations in the columns of X
for nn = 1:n
    [nn, n]

    % Initialize the residual with the observation x
    % For the modification with masking make sure that you only take into
    % account the known observations defined by the mask M
    R = X(:, nn);

    % Initialize z to zero
    z = zeros(l, 1);

    threshold = sigma*norm(X(:, nn));
    rc_max = +inf;

    while (norm(R) > threshold && (abs(rc_max) > rc_min))
      % Select atom with maximum absolute correlation to the residual
      % Update the maximum absolute correlation
      rc_max = 0;
      best_atom = 0;

      results = R'*U;
      [tilde, best_atom] = max(abs(results));
      
      rc_max = results(best_atom);

      % Update coefficient vector z and residual z
      R = R - rc_max*U(:, best_atom);
      z(best_atom) = z(best_atom) + rc_max;
    end
    
    % Add the calculated coefficient vector z to the overall matrix Z
    Z(:,nn) = z;
end
