function Z = sparseCoding(U, X, M_orig, sigma, rc_min)
%
% Perform sparse coding using a modified matching pursuit tailored to the
% inpainting problem with residual stopping criterion.
%
% INPUT
% U: (d x l) unit norm atoms
% X: (d x n) observations
% M: (d x n) mask denoting which observations are unknown
% sigma: residual error stopping criterion, normalized by signal norm
% rc_min: minimal residual correlation before stopping
%
% OUTPUT
% Z: MP coding
%

l = size(U,2);
n = size(X,2);

Z = zeros(size(X));

num_atoms = size(U, 2);

% Loop over all observations in the columns of X
for nn = 1:n
    [nn, n]

    % Initialize the residual with the observation x
    % For the modification with masking make sure that you only take into
    % account the known observations defined by the mask M
    R = X(:, nn);
    M = M_orig(:, nn)>0;

    % Remove the missing pixels and corresponding ??? of Z
    masked_R = R;
    %delete those
    masked_R(M==0) = [];

    %Adapt U to fit size of masked_R
    masked_U = U;
    masked_U(M==0,:) = [];

    % Initialize z to zero
    z = zeros(l, 1);

    threshold = sigma*norm(X(:, nn));
    rc_max = +inf;

    while (norm(masked_R) > threshold && (abs(rc_max) > rc_min))
      % Select atom with maximum absolute correlation to the residual
      % Update the maximum absolute correlation
      rc_max = 0;
      best_atom = 0;

      results = masked_R'*masked_U;
      [tilde, best_atom] = max(abs(results));
      
      rc_max = results(best_atom);

      % Update coefficient vector z and residual z
      masked_R = masked_R - rc_max*masked_U(:, best_atom);
      z(best_atom) = z(best_atom) + rc_max;

      % For the inpainting modification make sure that you only consider
      % the known observations defined by the mask M
      %masked_R = M*R;
    end
    
    % Add the calculated coefficient vector z to the overall matrix Z
    Z(:,nn) = M.*X(:, nn) + (1-M).*(U*z);
end
