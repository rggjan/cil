function [T, I_trained] = determineThresholds(I_training_framed, val_mask, ...
                                              val_I, parameters)
  %DETERMINETHRESHOLDS Determines the best thresholds, reconstruction for each patch
  
  image_size = size(val_I, 1);
  num_patches = image_size / parameters.patch_size;
  pfs = parameters.patch_frame_size;
  ps = parameters.patch_size;

  T = zeros(num_patches);
  I_trained = I_training_framed;

  %Iterate over all patches
  for i = 1 : num_patches
    for j = 1 : num_patches
      best_t = 1;
      best_error = +Inf;
      best_P = 0;

      %Extract patches from image / mask / validation mask
      P_framed = I_training_framed( ...
                            ps * (i - 1) + 1 : ...
                            ps * i + 2 * pfs, ...
                            ps * (j - 1) + 1 : ...
                            ps * j + 2 * pfs);

      P_mask = val_mask(ps * (i - 1) + 1 : ...
                        ps * i, ...
                        ps * (j - 1) + 1 : ...
                        ps * j);

      P_validate = val_I(ps * (i - 1) + 1 : ...
                         ps * i, ...
                         ps * (j - 1) + 1 : ...
                         ps * j).*P_mask;

      %Prepare iteration
      dev = +Inf;
      middle = parameters.td_middle;
      stepsize = middle;
      errors = [Inf, Inf, Inf];
      %Ps: Reconstructed patches.
      Ps = {};
      % Calculate middle value once before loop.
      [errors(2), Ps{2}] = determineError(P_framed, middle, P_mask, P_validate, parameters);
      
      %DEBUG / Visualization
      middles = [middle];
      
      %Find best threshold iteratively
      while(stepsize > parameters.td_abortbelow_stepsize && dev > parameters.td_abortbelow_stdev)
        
        % Right value
        [errors(3), Ps{3}] = determineError(P_framed, middle+stepsize, P_mask, P_validate, parameters);
        % We know the middle one, dont need to calculate it
        
        if(middle ~= 0)
          % Left value - only if the middle isn't already at 0. 
          [errors(1), Ps{1}] = determineError(P_framed, middle-stepsize, P_mask, P_validate, parameters);
        else
          % Middle is 0 or smaller. 
          errors(1) = errors(3);
        end
          
        % Standard deviation to decide termination later.
        dev = std(errors);

        % Where do we go? To the minimum of the error
        [errors(2), idx] = min(errors);
        if(middle==0 && idx == 1)
          % We don't go left if we are at 0. Stay at 0.
          idx = 2;
        end
        % New middle = Best error position found.
        % Save our best calculated patch for later
        Ps{2} = Ps{idx};
        
        % Calculate new middle
        middle = middle + (idx-2)*stepsize;
        
        % Assert
        if(middle < 0)
          ME = MException('VerifyOutput:OutOfBounds', ...
             'Middle is below the allowable limit (below zero)');
          throw(ME)
        end
        
        % We half the step size
        stepsize = stepsize / 2;
        %DEBUG / Visualization
        middles = [middles middle];
      end

      if(false)
        %DEBUG Turn on if you want to see the evolution of the threshold
        errors = [];
        steps=[];
        for t = 0:0.1:20 % TODO use gradient descent or something...
          P_reduced = removeFrame(dimensionReduction(P_framed, t, parameters), ...
                                  parameters);

          % Make sure we do not fall outside the value range of an image
          P_reduced = boundImageValues(P_reduced);

          diff = P_reduced.*P_mask - P_validate;

          new_error = sum(sum(diff.*diff));

          errors = [errors, new_error];
          steps = [steps, t];
          
        end
        figure(2);
        plot(steps,errors);
        hold on;
        plot(middles,ones(size(middles)), 'or');
        axis([-10,20,0,1])
        hold off;
        figure(1);
        imshow(P_reduced);
        pause
      end
      
      % Save the threshold for this patch
      T(i, j) = middle;

      range_i = pfs + ps*(i-1) + 1 : pfs + ps * i;
      range_j = pfs + ps*(j-1) + 1 : pfs + ps * j;
      % Fit the reconstructed patch back into the image
      I_trained(range_i, range_j) = Ps{2};
    end
  end
end

function [err, P_reduced] = determineError(P_framed, t, P_mask, P_validate, parameters)
  % DETERMINEERROR Determine the error and reconstruction for given
  % parameters, image and mask
  
  % Reconstruct, remove the frame
  P_reduced = removeFrame(dimensionReduction(P_framed, t, parameters), ...
                          parameters);

  % Make sure we do not fall outside the value range of an image [0,1]
  P_reduced = boundImageValues(P_reduced);

  % Calculate error
  diff = P_reduced.*P_mask - P_validate;
  err = sum(sum(diff.*diff));

end


