function [ Z, U ] = estimateRolesAndAssignments(X)
  K = 5;

  [perm_size, user_size] = size(X);

  perm = randperm(user_size);
  U = X(:, perm(1:K));

  hamming_dist = +Inf;
  old_hamming_dist = +Inf;

  while hamming_dist < old_hamming_dist || hamming_dist == +Inf
    old_hamming_dist = hamming_dist;

    % Calculation of Z
    Z = zeros(K, user_size);
    for user = 1:user_size
      big_matrix = abs(U - repmat(X(:,user), 1, K));
      sums = sum(big_matrix, 1);
      [dev_null, index] = min(sums);
      Z(index, user) = 1;
    end

    % Calculation of U
    U = zeros(perm_size, K);
    for role = 1:K
      users = find(Z(role,:));
      U(:,role) = median(X(:,users),2);
    end

    hamming_dist = sum(sum(abs(X - U*Z)))
  end
