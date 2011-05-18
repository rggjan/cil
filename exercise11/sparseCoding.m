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
    % Initialize z to zero

    R = X(:, nn);
    M = diag(M_orig(:, nn)>0);
    masked_R = M*R;
    % TODO use vector instead of Matrix M
    z = zeros(l, 1);
    
    threshold = sigma*norm(X(:, nn));
    rc_max = +inf;

    while (norm(masked_R) > threshold && (rc_max > rc_min))
        % Select atom with maximum absolute correlation to the residual       
        % Update the maximum absolute correlation
        rc_max = -1;
        best_atom = 0;

        for i = 1:num_atoms
          rc = R'*U(:, i);
          if abs(rc) > abs(rc_max)
            rc_max = rc;
            best_atom = i;
          end
        end
        
        % Update coefficient vector z and residual z
        R = R - rc_max*U(:, best_atom);
        z(best_atom) = z(best_atom) + rc_max;
        
        % For the inpainting modification make sure that you only consider
        % the known observations defined by the mask M
        masked_R = M*R;
    end
    
    % Add the calculated coefficient vector z to the overall matrix Z
%    Z(:,nn) = z;
    Z(:,nn) = M*X(:, nn) + (eye(size(M, 1)) - M)*U*z;
end
