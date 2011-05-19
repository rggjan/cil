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

% TO BE FILLED