function X = my_im2col(I, patch)

% Provides the functionality of im2col function of the image processing
% toolbox.
%
% INPUT
% I: image
% patch: The size of the square patches extracted
% 
% OUTPUT
% X: (d x n) observations matrix. Obviously d=patch*patch and n is the 
%            number of patches extracted

% You can write a for-loop to extract the patches one by one and then 
% transform each patch to an 1D signal sequentially
% creating matrix X

% Cut into blocks and return them (vectorized)
numRowBl=size(I,1)/patch;
numColumnBl = size(I,2)/patch;

X = zeros(patch^2,  numRowBl*numColumnBl*3);
for c = 1:size(I,3)
   for i=1:numRowBl
        for j=1:numColumnBl
            X(:,(c-1)*numRowBl*numColumnBl + (i-1)*numColumnBl + j) = 
              reshape( I( ((i-1)*patch+1):i*patch, ((j-1)*patch+1):j*patch, c ), patch*patch, 1 );
        end
   end
end
