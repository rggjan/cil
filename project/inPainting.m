function I_rec = inPainting(I, mask)
  % Load parameters from file
  load('params.mat');

  % Start parametrized inpainting
  I_rec = inPaintingParameterized(I, mask, parameters);
end
