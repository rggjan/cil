% Measure approximation error for several images.

function [cost, avgQErr] = EvaluateInpaintingParameterized(parameters, missing_pixels_fract)  

  file_list = dir(); 
  rep=3;
  
  dir_length = length(dir);

  Errors_final = [];
  Times_final = [];

  parfor r = 1 : rep
     Errors = []; % mean squared errors for each image
     Times = [];
     for i = 3 : dir_length  % running through the folder

        file_name = file_list(i).name; % get current filename

        % Only keep the images in the loop
        if (length(file_name) < 5)
          continue;
        elseif ( max(file_name(end-4:end) ~= '2.png'))
          continue;
        end

        % Read image, convert to double precision and map to [0,1] interval
        I = imread(file_name);
        I = double(I) / 255;

        % Generate mask at random, with 60% missing pixels
        mask = ones(size(I));
        numpixels = size(I,1)*size(I,2);
        holes = randperm(numpixels);
        holes = holes(1:floor(missing_pixels_fract*numpixels));
        mask(holes) = 0;


        I_mask = I;
        I_mask(~mask) = 0;

        % Call the main inPainting function
        tic;
        I_rec = inPaintingParameterized(I_mask, mask, parameters);
        Times = [Times toc];

        % Measure approximation error
        Errors = [Errors mean(mean(mean( ((I - I_rec) ).^2)))];
     end
     Errors_final = [Errors_final Errors];
     Times_final = [Times_final Times];
  end
  
  avgQErr = mean(Errors_final);
 
  global global_best_cost 

  if (mean(Times_final) > 60)
    times_error = exp((mean(Times_final)/60)-1);
  else
    times_error = 0;
  end

  cost = 10000 * mean(Errors_final) + times_error;
  if (cost < global_best_cost)
    fprintf('\n-------------------------------\nFound new best params with cost %g\n', cost);
    global_best_cost = cost;
    best_cost = cost;
    parameters
    save('params.mat', 'best_cost', 'parameters');
    fprintf('-------------------------------\n')
  end
end
