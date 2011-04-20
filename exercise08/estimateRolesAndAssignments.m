function [ Z, U ] = estimateRolesAndAssignments(X)
  K = 2;

  [perm_size, user_size] = size(X);

  perm = randperm(user_size);
  U = X(:, perm(1:K));

  % Calculation of Z
  Z = zeros(K, user_size);
  for user = 1:user_size
    big_matrix = abs(U - repmat(X(:,user), 1, K));
    sums = sum(big_matrix, 1);
    [dev_null, index] = min(sums);
    Z(index, user) = 1;
  end

  % Calculation of U



  %%%%%%%%%%%%%%%%%%%%%%%%%%
  U = X(:,1:2);
  Z = zeros(2,size(X,2));
  Z(1,1) = 1;
  Z(2,2) = 1;
