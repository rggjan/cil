% EvaluateInpaintingParameterized
% ===============================
% Measure approximation error for several images.
% Adjusted function of the framework thatrepeats the evaluation step to compensate
% for randomness introduced by the random mask (fixed mask in the initially provided implementation)
function [cost, avgQErr] = EvaluateInpaintingParameterized(parameters, missing_pixels_fract)  
  file_list = dir(); 
  rep=2;
  
  dir_length = length(dir);

  Errors_final = [];
  Times_final = [];

  % Repeat rep times to compensate for noise due to the random mask
  % Parfor will do so in parallel, if possible
  parfor r = 1 : rep
    % Reduction variables (parfor)
    Errors = []; % mean squared errors for each image
    Times = [];
     
    % Search for pictures
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

      % Generate mask at random, with adjustable number missing pixels
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

    % Collect the errors and the times
    Errors_final = [Errors_final Errors];
    Times_final = [Times_final Times];
  end
  
  avgQErr = mean(Errors_final);
 
  % Following part is used for the optimization
  % Will store best found parameters into a file
  global global_best_cost 
  global computer_speed

  % Calculate speed of computer
  if (length(computer_speed) == 0)
    computer_speed = mean(Times_final)
  end

  % Do not use time in cost function when below 5 times starting speed seconds
  if (mean(Times_final) > computer_speed*5)
    times_error = exp((mean(Times_final)/(computer_speed*5))-1) - 1
  else
    times_error = 0;
  end

  % Calculate cost function
  cost = 10000 * mean(Errors_final) + times_error;

  % Output and save best parameters when found
  if (cost < global_best_cost)
    fprintf('\n-------------------------------\nFound new best params with cost %g\n', cost);
    global_best_cost = cost;
    best_cost = cost;
    parameters
    save('params.mat', 'best_cost', 'parameters');
    fprintf('-------------------------------\n')
  end
end
