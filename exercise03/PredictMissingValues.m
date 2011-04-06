function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

column_pred = zeros(size(X));
row_pred = zeros(size(X));

for i = 1:size(X, 1)
	row = X(i, :);
	row(row == nil) = mean(row(row ~= nil));
	row_pred(i, :) = row;
end

for i = 1:size(X, 2)
	column = X(:, i);
	column(column == nil) = mean(column(column ~= nil));
	column_pred(:, i) = column;
end

average = (column_pred + row_pred)/2;

X_pred = X;
X_pred(X == nil) = average(X == nil);

for k = [9, 6, 12]

	[U, D, V] = svd(X_pred, 0);
			
	U = U(:, 1:k);
	V = V(:, 1:k);
	D = D(1:k, 1:k);

	prediction = U*D*V';
	X_pred(X == nil) = prediction(X == nil);
	
end

% Find the optimal number of rounds and values for k by also using the test values
% for i = 1:5
% 
% 	[U, D, V] = svd(X_pred, 0);
% 	
% 	k_best = 0;
% 	mse_best = 10;
% 		
% 	for k = 1:20
% 		
% 		Uk = U(:, 1:k);
% 		Vk = V(:, 1:k);
% 		Dk = D(1:k, 1:k);
% 	
% 		prediction = Uk*Dk*Vk';
% 		X_pred(X == nil) = prediction(X == nil);
% 	
% 		mse = sqrt(mean((X_tst(X_tst ~= nil) - X_pred(X_tst ~= nil)).^2));
% 		
% 		if mse < mse_best
% 			mse_best = mse;
% 			k_best = k;
% 		end
% 		
% 	end
% 	
% 	Uk = U(:, 1:k_best);
% 	Vk = V(:, 1:k_best);
% 	Dk = D(1:k_best, 1:k_best);
% 
% 	prediction = Uk*Dk*Vk';
% 	X_pred(X == nil) = prediction(X == nil);
% 
% 	display(['k = ' num2str(k_best) ': error = ' num2str(mse_best)]);
% 	
% end
