function [z, U, loglike, Z] = gmm(data, nClusters, varargin)
% GMM   Gaussian Mixture Model with fixed diagonal covariance
% 
%   [z, U, loglike, Z] = gmm(data, nClusters, varargin)
%   Input:
%       data        Data matrix, columns are observations
%       nClusters   Number of clusters
%
%   Output:
%       z           Cluster label vector
%       U           Matrix, columns are estimated cluster means
%       loglike     log-likelihood of the data.
%       Z           responsibilities.
%
%   Additional parameters through varargin
%       threshold   Stop if change of log-likelihood smaller than threshold,
%                   the default is 1e-2.
%       maxIter     Maximum number of iterations, the default is 100.
%       means       Initialization of the cluster centroids.
%       variance    We fix the variance to variance*I, the default is 1e-3.


% initializations
threshold = 1e-2;
maxIter = 100;
[nDims, nExamples] = size(data);
Z = zeros(nClusters, nExamples);
loglike = -realmax;
change = threshold+1;
iterations = 0;
variance = 1e-3;

% initialization of the class means
indices = randperm(nExamples);
U = data(:,indices(1:nClusters));

% uniform prior
pi = (1/nClusters)*ones(nClusters,1);

% parse varargin
for k=1:2:length(varargin)
    switch lower(varargin{k})
    case 'threshold'
        threshold = varargin{k+1};
    case 'maxiter'
        maxIter = varargin{k+1};
    case 'means'
        U = varargin{k+1};
    case 'variance'
        variance = varargin{k+1};
    otherwise
        error(['Unknown parameter ''' varargin{k} '''.']);
    end
end

% initialize covariance matrices
Sigma = zeros(nDims, nDims, nClusters);
for k=1:nClusters
    Sigma(:,:,k) = diag(variance*ones(nDims,1));
end


% GMM algorithm
while (change>threshold && iterations < maxIter),
    iterations = iterations+1;
    disp(sprintf('Iterations = %d  Loglikelihood = %0.5g  Change = %0.5g.', ...
                    iterations, loglike, change));

    % E-step: estimate responsibilities
    for k=1:nClusters
        Z(k,:) = LogGaussPDF(data, U(:,k), Sigma(:,:,k));
    end
    Z = exp(Z);
    Z = Z.*repmat(pi, [1 nExamples]);
    mass = sum(Z,1);
    P = Z;
    Z = Z./repmat(mass, nClusters, 1);
    
    % M-step: estimate parameters
    for k=1:nClusters
      Zpart = repmat(Z(k, :), nDims, 1);
      average_matrix = Zpart .* data;
      Nk = sum(Z(k, :));
      new_u = sum(average_matrix, 2)/Nk;

      U(:, k) = new_u;

      pi(k) = Nk / nExamples;
    end

    % estimate change of log-likelihood
    loglike_old = loglike;
    loglike = sum(log(sum(P,1))); % TODO change to mass
    change = loglike - loglike_old;
end

% convert assignments to vector representation
[foo, z] = max(Z, [], 1);


%----------------------------------------------------------------------------
function P = LogGaussPDF(data, u, Sigma)

[nDims, nExamples] = size(data);

P = data-repmat(u,1,nExamples);
P = sum(P.*(inv(Sigma)*P), 1);
P = -0.5*P - log(sqrt((2*pi)^nDims * (abs(det(Sigma))+realmin)));
