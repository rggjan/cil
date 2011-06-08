function I_rec = inPainting(I, mask)

parameters.gauss_size = 10;
parameters.gauss_sigma = 0.8;

parameters.patch_size = 16;
parameters.patch_frame_size = 8;

parameters.validation = 0.5; % Fraction of pixels used for validating the threshold
parameters.iterative = false;
parameters.max_iterations = 4;

I_rec = inPaintingParameterized(I, mask, parameters);
