function I_rec = inPainting(I, mask)

parameters.gauss_size = 5;
parameters.gauss_sigma = 0.8;

parameters.patch_size = 16;
parameters.patch_frame = 8;

parameters.validation = 0.5; % Fraction of pixels used for validating the threshold
parameters.iterations = 4;

I_rec = inPaintingParameterized(I, mask, parameters);
