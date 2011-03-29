function [z, U, score] = k_means(data, nClusters, varargin)
% K_MEANS   k-means clustering
% 
%   [z, U, score] = k_means(data, nClusters, varargin)
%   Input:
%       data        Data matrix, columns are observations
%       nClusters   Number of clusters
%
%   Output:
%       z           Cluster label vector
%       U           Matrix, columns are estimated cluster means
%       score       Negative log-likelihood of the estimated solution
%                   given the data.
%
%   Additional parameters through varargin
%       threshold   Stop if change of log-likelihood smaller than threshold,
%                   the default is 1e-4.
%       maxIter     Maximum number of iterations, the default is 100.
%       means       Initialization of the cluster centroids.


% initializations
threshold = 1e-4;
maxIter = 100;
[nDims, nExamples] = size(data);
Z = zeros(nClusters, nExamples);
score = realmax;
change = threshold+1;
iterations = 0;

% initialization of the class means
indices = randperm(nExamples);
U = data(:,indices(1:nClusters));

% parse varargin
for k=1:2:length(varargin)
    switch lower(varargin{k})
    case 'threshold'
        threshold = varargin{k+1};
    case 'maxiter'
        maxIter = varargin{k+1};
    case 'means'
        U = varargin{k+1};
    otherwise
        error(['Unknown parameter ''' varargin{k} '''.']);
    end
end

% k-Means algorithm
while (change>threshold && iterations < maxIter),
    iterations = iterations+1;
    disp(sprintf('Iterations = %d  Change = %0.5g.', iterations, change));

    % Assignment step: estimate class indices
    % TODO: fill in your code here
    
    % Update step: estimate means
    % TODO: fill in your code here

    % estimate change
    score_old = score;
    score = sum(sum((data - U*Z).^2, 1));
    change = score_old - score;
end

% convert assignments to vector representation
[foo, z] = max(Z, [], 1);
