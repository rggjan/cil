function I_rec = inPainting(I, mask)

parameters.gauss_size = 8.7392;
parameters.gauss_sigma = 0.6526;

% Is the exponent of the power of two
% due to the optimize script
parameters.patch_size = 7.4459;
parameters.patch_frame_size = 8.7963;

% Parameters for determining thresholds in Fourier
% Is the negative exponent of the power of 10
% due to the optimize script
parameters.td_abortbelow_stdev = 0.2479;
parameters.td_abortbelow_stepsize = 2.6688;

parameters.td_middle = 6.7928;
parameters.validation = 0.0518; % Fraction of pixels used for validating the threshold

parameters.iterative = true;         % Enable or disable iterative scheme

% Parameters for iterative scheme  
parameters.max_iterations = 4.1118;      % (Hard) abort criterion for iterations
parameters.abortbelow_change = 0.1948; % Minimal percentage change in error such that iterations continue. Tradeoff Speed-Accuracy

I_rec = inPaintingParameterized(I, mask, parameters);
