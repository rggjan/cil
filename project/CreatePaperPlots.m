% CreatePaperPlots
% ================
% Script to create plots and figures used in the paper. (CAVEAT: Takes long!)

% Create Error vs. MissingPixels Plot
% Requires parameters saved in a parameters.mat file

load('params.mat');

stepsize = 2;
no_steps = floor(100/stepsize);

% Init arrays
error_algo = zeros(no_steps, 1);
error_base1 = zeros(no_steps, 1);
error_base2 = zeros(no_steps, 1);
error_base3 = zeros(no_steps, 1);

main_path = pwd;

fprintf('1) Calculating error vs. missing pixels\n')
fprintf('1A) New algorithm\n')

if(~exist('plots/error_A.mat', 'file'))
  % Use parallel computation for this, if available
  parfor k=0:no_steps
    % Our algorithm
    [unused, e] = EvaluateInpaintingParameterized(parameters,stepsize*k/100);
    error_algo(k+1) = e/(k*stepsize/100);% Normalized
  end
  save('plots/error_A.mat', 'error_algo');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_A.mat');
end

fprintf('1B) Baseline 1\n')
if(~exist('plots/error_B1.mat', 'file'))    
  cd('baseline1/')
  parfor k=0:no_steps
    % Baseline 1
    error_base1(k+1) = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  save('plots/error_B1.mat', 'error_base1');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B1.mat');
end

fprintf('1C) Baseline 2\n')
if(~exist('plots/error_B2.mat', 'file'))    
  cd('baseline2/')
  parfor k=0:no_steps
    % Baseline 2
    error_base2(k+1) = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  save('plots/error_B2.mat', 'error_base2');
else
  fprintf('Found saved data file. Loading...\n')
  load('plots/error_B2.mat');
end

  fprintf('1D) Baseline 3\n')
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

fprintf('1) Plotting\n')

handle = figure;
range = 0:stepsize:100;
hold on;
xlabel('Missing pixels (%)');
ylabel('Average squared error per missing pixel');
plot(range, error_algo, 'r', range, error_base1,'b', range, error_base2, 'g', range, error_base3, 'y');
legend('New algorithm', 'Baseline 1 (Linear Interpolation)', 'Baseline 2 (Matching Pursuit)', 'Baseline 3 (Gaussian Interpolation)');
saveas(handle, 'plots/missingpixelsVsError.fig');
hold off;
