% Measure approximation error for several images.

function cost = EvaluateInpaintingParameterized(parameters)
  file_list = dir(); 
  k = 1;

  Errors = []; % mean squared errors for each image
  Times = [];

  for i = 3 : length(dir) % running through the folder

    file_name = file_list(i).name; % get current filename

    % Only keep the images in the loop
    if (length(file_name) < 5)
      continue;
    elseif ( max(file_name(end-4:end) ~= '2.png'))
      continue;
    end
    mask_name = [file_name(1:end-4) '_mask.png'];

    % Read image, convert to double precision and map to [0,1] interval
    I = imread(file_name);
    I = double(I) / 255;

    % Read the respective binary mask
    % EVALUATION IS DONE WITH A FIXED MASK
    mask = imread(mask_name);

    I_mask = I;
    I_mask(~mask) = 0;

    % Call the main inPainting function
    tic;
    I_rec = inPaintingParameterized(I_mask, mask, parameters);
    Times(k) = toc;

    % Measure approximation error
    Errors(k) = mean(mean(mean( ((I - I_rec) ).^2)));

    k = k+1;
  end
  
  sprintf('error: %f', mean(mean(Errors)));
  sprintf('times: %f', mean(mean(Times)));

  timemax = 90;
  errormax = 0.001;
  global mincost
  global best_params

  cost = (1-exp(mean(Errors)/errormax))*(1-exp(mean(Times)/timemax));
  if (length(mincost) == 0 || cost < mincost)
    fprintf('\n-------------------------------\nFound new best params with cost %g', cost);
    mincost = cost;
    best_params = parameters
    fprintf('-------------------------------\n\n')
  end
end
