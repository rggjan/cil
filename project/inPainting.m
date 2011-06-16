function I_rec = inPainting(I, mask)

parameters.gauss_size = 9.9946;
parameters.gauss_sigma = 0.8014;

% Is the exponent of the power of two
% due to the optimize script
parameters.patch_size = 4.9462;
parameters.patch_frame_size = 8;

% Parameters for determining thresholds in Fourier
% Is the negative exponent of the power of 10
% due to the optimize script
parameters.td_abortbelow_stdev = 2.6926;
parameters.td_abortbelow_stepsize = 1.9213;

parameters.td_middle = 9.9803;
parameters.validation = 0.1978; % Fraction of pixels used for validating the threshold

parameters.iterative = true;         % Enable or disable iterative scheme

% Parameters for iterative scheme  
parameters.max_iterations = 1;      % (Hard) abort criterion for iterations
parameters.abortbelow_change = 0.15; % Minimal percentage change in error such that iterations continue. Tradeoff Speed-Accuracy

I_rec = inPaintingParameterized(I, mask, parameters);
