function [U,Z] = dictionary_learning(I)
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

%global PRM;
% 
% l = PRM.dictionary_learning.l;
% init_mode = PRM.dictionary_learning.init_mode;     
% iter_num = PRM.dictionary_learning.iter_num;
% sigma = PRM.dictionary_learning.sigma;

l = 5;
init_mode = 'samples';
iter_num = 3;
sigma = 0.4;
rc_min = 0.1;
neib = 16;

X = my_im2col(I, neib);  

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
U = bsxfun(@rdivide, U, sqrt(sum(U.^2)));

% add constant atom as a first column of U
% and normalize
U(:,1) = ones(d,1)/sqrt(d);

%% Alternating Update of U and Z

Z = zeros(l,n);
%U_new = zeros(size(U));

for i=1:iter_num
    disp(['iteration: ' num2str(i)]);
    
    % Update Z
     Z = mp(U, X, sigma, rc_min);   
    
    % Update each atom
    % TODO Use UNew?
    
    P = randperm(l-1)+1;
    for a = P
      R = X-U*Z;
      R = R + U(:,a)*Z(a,:);
      [UU,tilde,tilde] = svd(R);
      % U_new(:,a) = UU(:,1);
      U(:,a) = UU(:,1);
    end

    %figure
    %imshow(I);
    %pause
    figure
    new_I = my_col2im(U*Z, neib, size(I, 1));
    imshow(new_I);
    pause
    figure
    U
    imagesc(reshape(U(:,2:l), neib, []))
    axis image
    pause
    
    %U(:,2:end) = U_new(:,2:end);
end
