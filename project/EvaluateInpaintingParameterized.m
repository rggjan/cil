% Measure approximation error for several images.

function error = EvaluateInpaintingParameterized(parameters)

file_list = dir(); 
k = 1;

Errors = []; % mean squared errors for each image

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
	I_rec = inPainting(I_mask, mask);
	
	% Measure approximation error
	Errors(k) = mean(mean(mean( ((I - I_rec) ).^2)));
	
	k = k+1;
end

error = mean(Errors);
