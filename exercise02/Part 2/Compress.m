% Compressing function
function I_comp = Compress(I)
  d = 16;
  k = 200;  

  X = extract(I, d);
  [mu, lambda, U] = PCAanalyse(X)

  dims = size(X);
  Xm = X - repmat(mu, 1, dims(2));

  Uk = U(:, 1:k);
  Z = Uk' * Xm;

  I_comp.Uk = Uk;
  I_comp.Z = Z;
  I_comp.mu = mu;
end


function [mu, lambda, U] = PCAanalyse(X)
  mu = mean(X, 2);

  [U, D] = eig(cov(X'));
  
  lambda = diag(D);
end

function X = extract(I,d)
    %Replicate the last column/row until it is divisible by d

    if (mod(size(I,1), d)) ~= 0
       % Copy row
       copy = repmat( I(size(I,1),:,:), (d-mod(size(I,1), d)) , 1);
       size(I)
       size(copy)
       I = [I; copy];

    end

    if (mod(size(I,2),d)) ~= 0
       % Copy column
       copy2 = repmat(I(:,size(I,2),:), 1, (d-mod(size(I,2), d)));
       size(I)
       size(copy2)
       I = [I copy2];
    end
    
    % Now we are guaranteed to have a matrix that is square, with each
    % dimension divisible by d

    % Cut into blocks and return them (vectorized)
    numRowBlocks=size(I,1)/d;
    numColumnBlocks = size(I,2)/d;

    X = zeros(d^2,  numRowBlocks*numColumnBlocks*3);
    for c = 1:3
       for i=1:numRowBlocks
            for j=1:numColumnBlocks
                X(:,(c-1)*numRowBlocks*numColumnBlocks + (i-1)*numColumnBlocks + j) = reshape(I( ((i-1)*d+1):i*d , ((j-1)*d+1):j*d,c),d*d,1);
            end
            
       end
    end

end
