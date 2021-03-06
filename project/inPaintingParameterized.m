% inPaintingParametrized
% ======================
% INPUT
% I: Masked image (n x n)
% mask: Mask itself (n x n)
% parameters: Parameters (as an object)
%
% OUTPUT
% I_rec: Reconstructed image
function I_rec = inPaintingParameterized(I, mask, parameters)
  % Make sure that parameters do have possible values
  % Round floating point values that come from optimizing
  parameters.gauss_size = round(parameters.gauss_size);
  parameters.patch_size = 2^round(parameters.patch_size);
  parameters.patch_frame_size = round(parameters.patch_frame_size);
  parameters.max_iterations = round(parameters.max_iterations); 
  parameters.td_abortbelow_stdev = 10^-(parameters.td_abortbelow_stdev);
  parameters.td_abortbelow_stepsize = 10^-(parameters.td_abortbelow_stepsize);
 

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

  % Delete pixels that we do not know in the training set
  I_training(val_indices) = 0;
  mask_training = mask;
  mask_training(val_indices) = 0;

  % Do Gauss interpolation
  I_training = gaussInterpolate(I_training, mask_training, parameters);

  % Create a frame around the image
  I_training_framed = createFrame(I_training, parameters);
  % Dito: Mask
  mask_training_framed = createFrame(mask_training, parameters);

  if (parameters.iterative)
    % Iterative version
    previous_error = +Inf;

    for i = 1:parameters.max_iterations
      % Find the thresholds
      [T, I_trained] = determineThresholds(I_training_framed, val_mask, I, parameters);
      
      % Composite the image with known stuff
      I_training_framed = I_training_framed.*mask_training_framed + ...
                          (1-mask_training_framed).*I_trained;
      % Calculate error
      diff = (removeFrame(I_training_framed, parameters) - I).*val_mask;
      err = sum(sum(diff.*diff));
      if(1/previous_error*err > 1-parameters.abortbelow_change)
        % No significant improvement anymore. Ending iteration
        break;
      end
      previous_error=err;
    end

    % Write back the image
    I_final = I_training_framed;
  else
    % Non-iterative variant
    I_framed = createFrame(I, parameters);
    mask_framed = createFrame(mask, parameters);
    I_framed = gaussInterpolate(I_framed, mask_framed, parameters);

    % Apply to original data
    [T, I_trained] = determineThresholds(I_training_framed, val_mask, I, parameters);
    I_final = dimensionReduction(I_framed, T, parameters);
  end

  % Composite the image back together and return it
  I_rec = I.*mask + (1-mask).*removeFrame(I_final, parameters);
end
