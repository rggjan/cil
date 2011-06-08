function [T, I_trained] = determineThresholds(I_training_framed, val_mask, ...
                                              val_I, parameters)
  image_size = size(val_I, 1);
  num_patches = image_size / parameters.patch_size;
  pfs = parameters.patch_frame_size;
  ps = parameters.patch_size;

  T = zeros(num_patches);
  I_trained = I_training_framed;

  for i = 1 : num_patches
    for j = 1 : num_patches
      best_t = 1;
      best_error = +Inf;
      best_P = 0;

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

      for t = 1:10 % TODO use gradient descent or something...
        P_reduced = removeFrame(dimensionReduction(P_framed, t, parameters), ...
                                parameters);
        diff = P_reduced.*P_mask - P_validate;

        new_error = sum(sum(diff.*diff));
        if (new_error < best_error)
          best_error = new_error;
          best_t = t;
          best_P = P_reduced;
        end
      end
      T(i, j) = best_t;

      range_i = ps * (i-1) + 1:ps * i;
      range_j = ps * (j-1) + 1:ps * j;    
      I_trained(range_i, range_j) = best_P;
    end
  end
end
