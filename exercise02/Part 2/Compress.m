% Compressing function
function I_comp = Compress(I)

  d = 16;
  k = 64;  

  [X, I_comp.numRowBlocks, I_comp.numColumnBlocks, I_comp.extendedX, I_comp.extendedY] = extract(I, d);
  [mu, lambda, U] = PCAanalyse(X);

  dims = size(X);
  Xm = X - repmat(mu, 1, dims(2));
  Uk = U(:, size(U,2)-k+1:size(U,2));
  Z = Uk' * Xm;

  I_comp.Uk = Uk;
  I_comp.Z = Z;
  I_comp.mu = mu;
  I_comp.d = d;
  I_comp.color_channels = size(I,3);
end


function [mu, lambda, U] = PCAanalyse(X)
  mu = mean(X, 2);

  [U, D] = eig(cov(X'));
  
  lambda = diag(D);
end

function [X,numRowBl,numColumnBl, extX, extY] = extract(I,d)

    %Copy the last row until height is divisible by d    
    if (mod(size(I,1), d)) ~= 0
       extX = d-mod(size(I,1), d);
       % Copy row
       copy = repmat( I(size(I,1),:,:), (d-mod(size(I,1), d)) , 1);
       I = [I; copy];
    else
        extX = 0;
    end
    
    %Copy the last column until width is divisible by d
    if (mod(size(I,2),d)) ~= 0
        extY = d-mod(size(I,2), d);
       % Copy column
       copy2 = repmat(I(:,size(I,2),:), 1, (d-mod(size(I,2), d)));
       I = [I copy2];
    else
        extY = 0;
    end
    
    % Now we are guaranteed to have a matrix that is square, with each
    % dimension divisible by d

    % Cut into blocks and return them (vectorized)
    numRowBl=size(I,1)/d;
    numColumnBl = size(I,2)/d;

    X = zeros(d^2,  numRowBl*numColumnBl*3);
    for c = 1:size(I,3)
       for i=1:numRowBl
            for j=1:numColumnBl
                X(:,(c-1)*numRowBl*numColumnBl + (i-1)*numColumnBl + j) = reshape( I( ((i-1)*d+1):i*d , ((j-1)*d+1):j*d, c ), d*d, 1 );
            end
            
       end
    end

end
