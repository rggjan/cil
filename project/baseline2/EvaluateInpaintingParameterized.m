% Measure approximation error for several images.

function [avgQErr] = EvaluateInpaintingParameterized(missing_pixels_fract)  

  file_list = dir('..'); 
  rep=3;
  
  dir_length = length(dir('..'));

  Errors_final = [];
  LTimes_final = [];

  parfor r = 1 : rep
     Errors = []; % mean squared errors for each image
     LTimes = [];
     for i = 3 : dir_length  % running through the folder

        file_name = file_list(i).name; % get current filename

        % Only keep the images in the loop
        if (length(file_name) < 5)
          continue;
        elseif ( max(file_name(end-4:end) ~= '2.png'))
          continue;
        end

        % Read image, convert to double precision and map to [0,1] interval
        I = imread(strcat('../',file_name));
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
        I_rec = inPainting(I_mask, mask);
        LTimes = [LTimes toc];

        % Measure approximation error
        Errors = [Errors mean(mean(mean( ((I - I_rec) ).^2)))];
     end
     Errors_final = [Errors_final Errors];
     LTimes_final = [LTimes_final LTimes];
  end
  
  avgQErr = mean(Errors_final);


end
