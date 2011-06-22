% Measure approximation error for several images.

function [avgQErr, stdev, stdev_runs, stdev_diff] = EvaluateInpaintingParameterizedStatistics(missing_pixels_fract, rep, inPainting)
  file_list = dir('.'); 
  
  dir_length = length(dir('.'));

  Errors_final = [];
  Error_means = [];
  stdev_diffs = [];

  for r = 1 : rep
    fprintf('At rep %d \n', r)
     Errors = []; % mean squared errors for each image
     for i = 3 : dir_length  % running through the folder

        file_name = file_list(i).name; % get current filename

        % Only keep the images in the loop
        if (length(file_name) < 5)
          continue;
        elseif ( max(file_name(end-4:end) ~= '2.png'))
          continue;
        end
        fprintf('At file %s\n', file_name)

        % Read image, convert to double precision and map to [0,1] interval
        I = imread(strcat('./',file_name));
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
        I_rec = inPainting(I_mask, mask);

        % Measure approximation error
        Errors = [Errors mean(mean(mean( ((I - I_rec) ).^2)))];
     end
     Errors_final = [Errors_final Errors];
     Error_means = [Error_means mean(Errors)];
     stdev_diffs = [stdev_diffs std(Errors)];
  end
  
  avgQErr = mean(Errors_final);
  
  % Determine mean and stdev per image
  % Count images first
  imc = 0;
  filenames = {};
  for i = 3 : dir_length
    file_name = file_list(i).name; % get current filename
    % Only keep the images in the loop
      if (length(file_name) < 5)
       continue;
      elseif ( max(file_name(end-4:end) ~= '2.png'))
       continue;
      end
      %Count and save filenames for later
      imc = imc+1;
      filenames{imc} = {file_name};
  end
  
  for i=1:imc
    stdev{i,2} = filenames{i};
  end
  
  if rep > 1
    for i=1:imc
      stdev{i,1} = std(Errors_final(i:imc:end));
    end
    stdev_runs = std(Error_means);
  else
    % 1 Iteration - no deviation
    for i=1:imc
      stdev{i,1} = 0;
    end
    stdev_runs = 0;
  end
  stdev_diff = mean(stdev_diffs);
end
