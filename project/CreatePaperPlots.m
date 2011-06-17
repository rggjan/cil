% Create Error vs. MissingPixels Plot
% Requires parameters saved in a parameters.mat file

load('params.mat');

  stepsize = 2;
  no_steps = floor(100/stepsize);
  error = zeros(no_steps, 1);

  %Use parallel computation for this
  parfor k=0:no_steps

    [unused, e] = EvaluateInpaintingParameterized(parameters,stepsize*k/100);
    % Normalized
    error(k+1) = e/(k*stepsize/100);
    
  end
  
  handle = figure;
  hold on;
  xlabel('Missing pixels (%)');
  ylabel('Average squared error per missing pixel');
  plot(0:stepsize:100, error);
  saveas(handle, 'plots/missingpixelsVsError.png');
  hold off;
  
  
  