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


if strcmp(init_mode, 'rand')
    
    % Initialize D with random unit length atoms
    
elseif strcmp(init_mode, 'samples')
    
    % Draw uniform samples from data matrix
else
    error('Invalid value for parameter init_mode.')
end

% add constant atom as a first column of U


%% Alternating Update of U and Z

Z = zeros(l,n);
U_new = zeros(size(U));

for i=1:iter_num
    disp(['iteration: ' num2str(i)]);
    
    % Update Z
     Z = mp(U, X, sigma, rc_min);   
    
    % Update each atom
    for a = some_order       
        % update U_new(:,a)
    end
    
    U(:,2:end) = U_new(:,2:end);
    
end
