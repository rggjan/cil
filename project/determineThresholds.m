function [T, I_trained] = determineThresholds(I_training_framed, val_mask,
                                              val_I)
  image_size = size(val_I, 1);
  num_patches = image_size / parameters.patch_size;
  pfs = parameters.patch_frame_size;

  T = zeros(num_patches);

  for i = 1 : num_patches
    for j = 1 : num_patches
      best_t = 1;
      best_error = +Inf;

      P_framed = I_training_framed(
                            pfs * (i - 1) + 1 : ...
                            pfs * i + 2 * parameters.patch_frame, ...
                            pfs * (j - 1) + 1 : ...
                            pfs * j + 2 * parameters.patch_frame);

      P_mask = val_mask(pfs * (i - 1) + 1 : ...
                        pfs * i, ...
                        pfs * (j - 1) + 1 : ...
                        pfs * j);

      P_validate = val_I(pfs * (i - 1) + 1 : ...
                         pfs * i, ...
                         pfs * (j - 1) + 1 : ...
                         pfs * j).*P_mask;

      for t = 1:10
        P_reduced = removeFrame(dimensionReduction(P_framed, t, parameters),
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

      range_i = parameters.patch_size * (i-1) + 1:parameters.patch_size * i;
      range_j = parameters.patch_size * (j-1) + 1:parameters.patch_size * j;    
      I_trained(range_i, range_j) = best_P;
    end
  end
end
