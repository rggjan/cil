function I_rec = inPainting(I, mask)

% Baseline 1: Perform linear inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hidding image information
%
% OUTPUT
% I_rec = Reconstructed image 

global U;

% Parameters
rc_min = 0.01; % rc_min: minimal residual correlation before stopping
neib = 32; % neib: The patch sizes used in the decomposition of the image
sigma = 0.01; % sigma: residual error stopping criterion, normalized by signal norm

% Get patches of size neib x neib from the image and the mask and
% convert each patch to 1D signal

[w, h] = size(I);

for x=1:w
  for y=1:h
    if mask(x, y) == 0
      values = 0;
      s = 0;

      % Try-Catch to ignore boundary issues
      for i=1:w
        try
          if mask(x+i, y) ~= 0
            values = values + I(x+i, y)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for i=1:h
        try
          if mask(x, y+i) ~= 0
            values = values + I(x, y+i)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for i=1:h
        try
          if mask(x, y-i) ~= 0
            values = values + I(x, y-i)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for i=1:w
        try
          if mask(x-i, y) ~= 0
            values = values + I(x-i, y)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      I(x, y) = values / s;
    end
  end
end
    

% You need to do the image reconstruction using the known image information
% and for the missing pixels use the reconstruction from the sparse coding.
% The mask will help you to distinguish between these two parts.
%I_rec = my_col2im(Z, neib, size(I, 1));
I_rec = I;
