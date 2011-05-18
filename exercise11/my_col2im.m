function I_rec = my_col2im(X, patch, im_size)

% Provides the functionality of col2im function of the image processing
% toolbox.
%
% INPUT
% X: (d x n) observations matrix. Obviously d=patch*patch and n is the 
%            number of patches extracted
% patch: The size of the square patches extracted
% im_size: Size of the original image 
%
% OUTPUT
% I_rec: image

% It will only work for orthogonal matrices and exact patches coverage

row=1;
column=1;

out = zeros(im_size, im_size);

numColumnBlocks = im_size/patch;

for i=1:size(X,2)
  out((row-1)*patch+1:row*patch, (column-1)*patch+1:column*patch) = reshape(X(:,i)), patch, patch);
    
  if(numColumnBlocks == column)
     column=1;
     row=row+1;
  else
     column=column+1;
  end
end
