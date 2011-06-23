% CreatePaperPlots
% ================
% Script to create plots and figures used in the paper. (CAVEAT: Takes long!)

% Create Error vs. MissingPixels Plot
% Requires parameters saved in a parameters.mat file

load('start_params.mat');
main_path = pwd;

% Generate strategy plots
global debug_threshold_plot_number;
fprintf('1) Creating Parameter evolution graphs\n')
debug_threshold_plot_number = 10;
 
[unused, error_a, stdev_a] = EvaluateInpaintingParameterized(parameters, 0.6, 1);
 
for i = 1:10
  f = open(sprintf('plots/search_strategy_%g.fig', i));
  plotpdftex(f, sprintf('plots/search_strategy_%g', i));
end

load('params.mat');
addpath('baseline1', 'baseline2', 'baseline3');

fprintf('2) Evaluating performance at 60%% missing pixels\n');
fprintf(' Note: Errors are NOT normalized\n')

fprintf('Working in inPainting ...\n')
[avgQErrA, stdevA, stdev_runsA, stdev_diffA] = EvaluateInpaintingParameterizedStatistics(0.6, 10, @inPainting)
save('plots/errsAndStdevA.mat', 'avgQErrA', 'stdevA', 'stdev_runsA', 'stdev_diffA');

fprintf('Working in baseline1 ...\n')
[avgQErrB1, stdevB1, stdev_runsB1, stdev_diffB1] = EvaluateInpaintingParameterizedStatistics(0.6, 10, @baseline1)
save('plots/errsAndStdevB1.mat', 'avgQErrB1', 'stdevB1', 'stdev_runsB1', 'stdev_diffB1');

fprintf('Working in baseline2 ...\n')
[avgQErrB2, stdevB2, stdev_runsB2, stdev_diffB2] = EvaluateInpaintingParameterizedStatistics(0.6, 10, @baseline2)
save('plots/errsAndStdevB2.mat', 'avgQErrB2', 'stdevB2', 'stdev_runsB2', 'stdev_diffB2');

fprintf('Working in baseline3 ...\n')
[avgQErrB3, stdevB3, stdev_runsB3, stdev_diffB3] = EvaluateInpaintingParameterizedStatistics(0.6, 10, @baseline3)
save('plots/errsAndStdevB3.mat', 'avgQErrB3', 'stdevB3', 'stdev_runsB3', 'stdev_diffB3');

% Generate graphs
stepsize = 2;
% Ignore the 100% - the runtime will be inacceptable
no_steps = floor(100/stepsize)-1;

% Init arrays
error_algo = zeros(no_steps, 1);
error_base1 = zeros(no_steps, 1);
error_base2 = zeros(no_steps, 1);
error_base3 = zeros(no_steps, 1);


fprintf('3) Calculating error vs. missing pixels\n')
fprintf('3A) New algorithm\n')

if(~exist('plots/error_A.mat', 'file'))
  % Use parallel computation for this, if available
  parfor k=0:no_steps
    % Our algorithm
    e = EvaluateInpaintingParameterizedStatistics(stepsize*k/100, 3, @inPainting);
    error_algo(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_A.mat', 'error_algo');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_A.mat');
end

fprintf('3B) Baseline 1\n')
if(~exist('plots/error_B1.mat', 'file'))    
  parfor k=0:no_steps
    % Baseline 1
    e = EvaluateInpaintingParameterizedStatistics(stepsize*k/100, 3, @baseline1);
    error_base1(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_B1.mat', 'error_base1');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B1.mat');
end

fprintf('3C) Baseline 2\n')
if(~exist('plots/error_B2.mat', 'file'))    
  parfor k=0:no_steps
    % Baseline 2
    e = EvaluateInpaintingParameterizedStatistics(stepsize*k/100, 3, @baseline2);
    error_base2(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_B2.mat', 'error_base2');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B2.mat');
end

  fprintf('3D) Baseline 3\n')
if(~exist('plots/error_B3.mat', 'file'))    
  parfor k=0:no_steps
    % Baseline 3
    e = EvaluateInpaintingParameterizedStatistics(stepsize*k/100, 3, @baseline3);
    error_base3(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_B3.mat', 'error_base3');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B3.mat');
end

fprintf('3E) Plotting\n')

handle = figure;
range = 0:stepsize:(no_steps*step_size);
hold on;
xlabel('Missing pixels (%)');
ylabel('Average squared error per missing pixel');
plot(range, error_algo, 'r', range, error_base1,'b', range, error_base2, 'g', range, error_base3, 'y');
legend('New algorithm', 'Baseline 1 (Linear Interpolation)', 'Baseline 2 (Matching Pursuit)', 'Baseline 3 (Gaussian Interpolation)');
saveas(handle, 'plots/missingpixelsVsError.fig');
hold off;

% Generate curves and search strategy plots
load('start_params.mat');
save('params.mat', 'best_cost', 'parameters');
OptimizeInpainting(100);
