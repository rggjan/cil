function I_rec = inPaintingParameterized(I, mask, parameters)

% Perform the actual inpainting of the image.

% INPUT
% I: Masked image (n x n)
% mask: Mask itself (n x n)
% parameters: Parameters (as an object)
%
% OUTPUT
% I_rec: Reconstructed image 

% Split into validation and training set
good_indices = find(mask);
num_good = length(good_indices);
perm = randperm(num_good);
val_indices = good_indices(perm(1:round(parameters.validation * num_good)));
val_mask = zeros(size(mask));
val_mask(val_indices) = 1;

% ----------------------------------
% | known                 | masked | = Input
% ----------------------------------
% | training | validation | masked | = Own Partitioning
% ----------------------------------

I_training = I;
I_training(val_indices) = 0;

mask_training = mask;
mask_training(val_indices) = 0;

I_training = gaussInterpolate(I_training, mask_training, parameters);

I_training_framed = createFrame(I_training, parameters);
mask_training_framed = createFrame(mask_training, parameters);

if (parameters.iterative)
  % TODO add stopping criterion based on validation set
  for i = 1:parameters.max_iterations
    [T, I_trained] = determineThresholds(I_training_framed, val_mask, I, parameters);
    I_training_framed = I_training_framed.*mask_training_framed + ...
                        (1-mask_training_framed).*I_trained;
    diff = (removeFrame(I_training_framed, parameters) - I).*val_mask;
    err = sum(sum(diff.*diff))
  end
  I_final = I_training_framed;
else
  I_framed = createFrame(I, parameters);
  mask_framed = createFrame(mask, parameters);
  I_framed = gaussInterpolate(I_framed, mask_framed, parameters);

  [T, I_trained] = determineThresholds(I_training_framed, val_mask, I, parameters);
  I_final = dimensionReduction(I_framed, T, parameters);
end

I_rec = I.*mask + (1-mask).*removeFrame(I_final, parameters);
