function [ Z, U ] = estimateRolesAndAssignments(X)
%this function is just a stub,
%you should write your own code here to solve the role mining problem
  U = X(:,1:2);
  Z = zeros(2,size(X,2));
  Z(1,1) = 1;
  Z(2,2) = 1;