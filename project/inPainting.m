% inPainting
% ==========
% A wrapper for inpainting parametrized, loading
% the default parameters. Takes as input the Image
% and a mask, showing what pixels are to be reconstructed.
function I_rec = inPainting(I, mask)
  % Load parameters from file
  load('params.mat');

  % Start parametrized inpainting
  I_rec = inPaintingParameterized(I, mask, parameters);
end
