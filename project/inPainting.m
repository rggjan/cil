function I_rec = inPainting(I, mask)

parameters.gauss_size = 10;
parameters.gauss_sigma = 0.8;

% Is the exponent of the power of two
% due to the optimize script
parameters.patch_size = 4;
parameters.patch_frame_size = 8;

% Parameters for determining thresholds in Fourier
parameters.td_abortbelow_stdev = 0.0001;
parameters.td_abortbelow_stepsize = 0.01;
parameters.td_middle = 10;

parameters.validation = 0.2; % Fraction of pixels used for validating the threshold

parameters.iterative = true;         % Enable or disable iterative scheme

% Parameters for iterative scheme  
parameters.max_iterations = 10;      % (Hard) abort criterion for iterations
parameters.abortbelow_change = 0.05; % Minimal percentage change in error such that iterations continue. Tradeoff Speed-Accuracy

I_rec = inPaintingParameterized(I, mask, parameters);
