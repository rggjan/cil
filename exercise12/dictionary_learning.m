function [U,Z] = dictionary_learning(X)
% Implements dictionary learning algorithm, using matching pursuit as the
% sparse coding stage.
%
% INPUTS
% X: (d x n) data matrix (samples as columns)
%
% OUTPUTS
% U: (d x l) dictionary
% Z: sparse coding of X in dictionary U
%
% PARAMETERS
% l: codebook size of dictionary
% init_mode: initialization of dictionary, either 'rand' or 'samples'
% iter_num: number of update iterations
% sigma: desired maximal residual norm

%% Parameters

global PRM;

l = PRM.dictionary_learning.l;
init_mode = PRM.dictionary_learning.init_mode;     
iter_num = PRM.dictionary_learning.iter_num;
sigma = PRM.dictionary_learning.sigma;


%% Initialization of Dictionary
d = size(X,1);
n = size(X,2);

if strcmp(init_mode, 'rand')
    
    % Initialize D with random atoms
    U = rand(d,l);
    
elseif strcmp(init_mode, 'samples')
    
    % Draw uniform samples from data matrix
    Perm = randperm(n);
    U = X(:,Perm(1:l));
    
else
    error('Invalid value for parameter init_mode.')
end

%funny function to normalize
U = bsxfun(@rdivide, A, sqrt(sum(A.^2)));

% add constant atom as a first column of U
% and normalize
U(:,1) = ones(d,1)/sqrt(d);

%% Alternating Update of U and Z

Z = zeros(l,n);
U_new = zeros(size(U));

for i=1:iter_num
    disp(['iteration: ' num2str(i)]);
    
    % Update Z
     Z = mp(U, X, sigma, rc_min);   
    
    % Update each atom
    % TODO Use UNew?
    for a = 1: size(U,2)
      R = X-U*Z;
      R = R + U(:,a)*Z(:,a);
      [UU,~,~] = svd(R);
      U_new(:,a) = UU(:,1);
    end
    
    U(:,2:end) = U_new(:,2:end);
    
end
