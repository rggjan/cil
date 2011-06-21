function I_rec = inPaintingParameterized(I, mask, parameters)

% Perform the actual inpainting of the image.

% INPUT
% I: Masked image (n x n)
% mask: Mask itself (n x n)
% parameters: Parameters (as an object)
%
% OUTPUT
% I_rec: Reconstructed image 

  % Make sure that parameters do have possible values
  % Round floating point values that come from optimizing
  parameters.gauss_size = round(parameters.gauss_size);
  parameters.patch_size = 2^round(parameters.patch_size);
  parameters.patch_frame_size = round(parameters.patch_frame_size);
  parameters.max_iterations = false; %Iterative not supported here
  %Unused parameters
  parameters.td_abortbelow_stdev = 0;
  parameters.td_abortbelow_stepsize = 0;
  parameters.abortbelow_change = 0;


  % Non-iterative variant: Gauss only
  I_framed = createFrame(I, parameters);
  mask_framed = createFrame(mask, parameters);
  I_framed = gaussInterpolate(I_framed, mask_framed, parameters);

% Composite the image back together and return it
I_rec = I.*mask + (1-mask).*removeFrame(I_framed, parameters);
