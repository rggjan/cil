mu1 = [1 1];
mu2 = [-1 -1];

X1 = randn(400,2) + repmat(mu1, [400, 1]);
X2 = randn(800,2) + repmat(mu2, [800, 1]);
X = [X1; X2];

[z, means] = gmm(X', 2, 'variance', 1);

% visualize the clustering
cols = jet(size(means,2));
figure;
for i=1:size(means,2)
    ind = find(z==i);
    plot(X(ind,1), X(ind,2), '.', 'Color', cols(i,:));
    hold on;
end
hold off;
