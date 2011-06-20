% Creates plots and figures used in the paper. (CAVEAT: Takes long!)

% Create Error vs. MissingPixels Plot
% Requires parameters saved in a parameters.mat file

  load('params.mat');

  stepsize = 2;
  no_steps = floor(100/stepsize);
  % Init arrays
  error_algo = zeros(no_steps, 1);
  error_base1 = zeros(no_steps, 1);
  error_base2 = zeros(no_steps, 1);
  
  main_path = pwd;
  
  fprintf('1) Calculating error vs. missing pixels\n')
  fprintf('1A) New algorithm\n')
  %Use parallel computation for this, if available
  parfor k=0:no_steps
    % Our algorithm
    [unused, e] = EvaluateInpaintingParameterized(parameters,stepsize*k/100);
    error_algo(k+1) = e/(k*stepsize/100);% Normalized
  end
  
  
  fprintf('1B) Baseline 1\n')
  cd('baseline1/')
  parfor k=0:no_steps
    %Baseline 1
    error_base1(k+1) = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)
  
  fprintf('1C) Baseline 2\n')
  cd('baseline2/')
  parfor k=0:no_steps
    %Baseline 1
    error_base2(k+1) = feval('EvaluateInpaintingParameterized', stepsize*k/100);
  end
  cd(main_path)

  fprintf('1) Plotting\n')
  
  handle = figure;
  range = 0:stepsize:100;
  hold on;
  xlabel('Missing pixels (%)');
  ylabel('Average squared error per missing pixel');
  plot(range, error_algo, 'r', range, error_base1,'b', range, error_base2, 'g');
  legend('New algorithm', 'Baseline 1 (linear)', 'Baseline 2 (Matching Pursuit)');
  saveas(handle, 'plots/missingpixelsVsError.fig');
  hold off;
  
  
  