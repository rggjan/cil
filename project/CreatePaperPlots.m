% CreatePaperPlots
% ================
% Script to create plots and figures used in the paper. (CAVEAT: Takes long!)

% Create Error vs. MissingPixels Plot
% Requires parameters saved in a parameters.mat file

load('params.mat');

% Generate strategy plots
global debug_threshold_plot_number;
fprintf('1) Creating Parameter evolution graphs')
debug_threshold_plot_number = 10;

EvaluateInpaintingParameterized(parameters, 0.6, 1);

for i = 1:10
  f = open(sprintf('plots/search_strategy_%g.fig', i));
  plotpdftex(f, sprintf('plots/search_strategy_%g', i));
end

% Generate graphs
stepsize = 2;
no_steps = floor(100/stepsize);

% Init arrays
error_algo = zeros(no_steps, 1);
error_base1 = zeros(no_steps, 1);
error_base2 = zeros(no_steps, 1);
error_base3 = zeros(no_steps, 1);

main_path = pwd;

fprintf('2) Calculating error vs. missing pixels\n')
fprintf('2A) New algorithm\n')

if(~exist('plots/error_A.mat', 'file'))
  % Use parallel computation for this, if available
  parfor k=0:no_steps
    % Our algorithm
    [unused, e, unused2] = EvaluateInpaintingParameterized(parameters,stepsize*k/100, 3);
    error_algo(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_A.mat', 'error_algo');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_A.mat');
end

fprintf('2B) Baseline 1\n')
if(~exist('plots/error_B1.mat', 'file'))    
  cd('baseline1/')
  parfor k=0:no_steps
    % Baseline 1
    [error_base1(k+1), unused] = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  save('plots/error_B1.mat', 'error_base1');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B1.mat');
end

fprintf('2C) Baseline 2\n')
if(~exist('plots/error_B2.mat', 'file'))    
  cd('baseline2/')
  parfor k=0:no_steps
    % Baseline 2
    [error_base2(k+1), unused] = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  save('plots/error_B2.mat', 'error_base2');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B2.mat');
end

  fprintf('2D) Baseline 3\n')
if(~exist('plots/error_B3.mat', 'file'))    
  cd('baseline3/')
  parfor k=0:no_steps
    % Baseline 3
    error_base3(k+1) = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  save('plots/error_B3.mat', 'error_base3');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B3.mat');
end

fprintf('2E) Plotting\n')

handle = figure;
range = 0:stepsize:100;
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
