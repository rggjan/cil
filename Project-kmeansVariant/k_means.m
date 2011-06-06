function [z, U, score] = k_means(data, mask, nClusters, varargin)
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
maxIter = 50;
[nDims, nExamples] = size(data);
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
    Z = zeros(nClusters, nExamples);
    iterations = iterations+1;
    disp(sprintf('Iterations = %d  Change = %0.5g.', iterations, change));

    % Assignment step: estimate class indices
    for(i=1:nExamples)
      % Get data
      dataline = data(:, i);
      maskline = mask(:, i);

      % Get indices that can be used
      indices = find(maskline==1);

      % Get shorter version, repeat
      masked_dataline = dataline(indices);
      
      pointMat = repmat(masked_dataline,1,nClusters);

      masked_U = U(indices, :);

      % Calculate distance to each centroid
      distance = (masked_U - pointMat).^2;

      % Get smallest distance and assign to cluster
      [tilde, ind] = min(sum(distance));
      Z(ind,i) = 1;
    end
    
    % Update step: estimate means
    
    % For each cluster, divide the '1's for all assigned points by the
    % total number of assigned points: Eliminates need to account for
    % denominator of cluster update function
    for(i=1:nClusters)
      list = Z(i, :);
      indices = find(list==1);

      my_items = data(:, indices);
      my_masks = mask(:, indices);

      U(:, i) = sum(my_items, 2)./ (sum(my_masks, 2) + eps);
    end

%    Zbar = Z ./ repmat(sum(Z,2),1,nExamples);
    
%    U = data * Zbar';

    % estimate change
    %score_old = score;
    %score = sum(sum((data - U*Z).^2, 1));
    %change = score_old - score;
end

% convert assignments to vector representation
[foo, z] = max(Z, [], 1);
