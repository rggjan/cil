function I_rec = inPaintingParameterized(I, mask, parameters)

% Perform the actual inpainting of the image.

% INPUT
% I: Masked image (n x n)
% mask: Mask itself (n x n)
% parameters: Parameters (as an object)
%
% OUTPUT
% I_rec: Reconstructed image 

% Split into validation and training set
good_indices = find(mask);
num_good = length(good_indices);
perm = randperm(num_good);
val_indices = good_indices(perm(1 : round(parameters.validation * num_good)));
val_mask = zeros(size(mask));
val_mask(val_indices) = 1;

I_training = I;
I_training(val_indices) = 0;

mask_training = mask;
mask_training(val_indices) = 0;

% Interpolate the missing pixels with Gaussian weighting.
I_training = gaussInterpolate(I_training, mask_training, parameters);
I_rec = gaussInterpolate(I, mask, parameters);

image_size = size(I, 1);

if mod(image_size, parameters.patch_size) ~= 0
	throw('The patch size does not divide the image size!');
end

num_patches = image_size / parameters.patch_size;
num_pixels = image_size + 2 * parameters.patch_frame;

I_rec_framed = zeros(num_pixels, num_pixels);
I_training_framed = zeros(num_pixels, num_pixels);

% Invert the mask (0 = keep, 1 = replace)
imask = logical(1 - mask);

% Repeat the dimension reduction in the Fourier domain k times.
for k = 1 : parameters.iterations
	
	% Frame the image by duplicating the first and last row respectively column.
	I_rec_framed(parameters.patch_frame + 1 : parameters.patch_frame + image_size, parameters.patch_frame + 1 : parameters.patch_frame + image_size) = I_rec;
	I_training_framed(parameters.patch_frame + 1 : parameters.patch_frame + image_size, parameters.patch_frame + 1 : parameters.patch_frame + image_size) = I_training;
	
	for i = 1 : parameters.patch_frame
		I_rec_framed(:, i) = I_rec_framed(:, parameters.patch_frame + 1);
		I_rec_framed(:, end - i + 1) = I_rec_framed(:, end - parameters.patch_frame);
		I_rec_framed(i, :) = I_rec_framed(parameters.patch_frame + 1, :);
		I_rec_framed(end - i + 1, :) = I_rec_framed(end - parameters.patch_frame, :);
	
		I_training_framed(:, i) = I_training_framed(:, parameters.patch_frame + 1);
		I_training_framed(:, end - i + 1) = I_training_framed(:, end - parameters.patch_frame);
		I_training_framed(i, :) = I_training_framed(parameters.patch_frame + 1, :);
		I_training_framed(end - i + 1, :) = I_training_framed(end - parameters.patch_frame, :);
	end
	
	for i = 1 : num_patches
		for j = 1 : num_patches
			P_framed = I_framed(parameters.patch_size * (i - 1) + 1 : parameters.patch_size * i + 2 * parameters.patch_frame, ...
					parameters.patch_size * (j - 1) + 1 : parameters.patch_size * j + 2 * parameters.patch_frame);
			P_fft = fft2(P_framed);
			P_abs = abs(P_fft);
			
			% perc = prctile(reshape(P_abs, 1, []), parameters.percentile);
			perc = 1;
			P_fft(abs(P_fft) < perc) = 0;
			P_ifft = abs(ifft2(P_fft));
			
			P_rec = P_ifft(parameters.patch_frame + 1 : end - parameters.patch_frame, parameters.patch_frame + 1 : end - parameters.patch_frame);
			
			range_i = parameters.patch_size * (i - 1) + 1 : parameters.patch_size * i;
			range_j = parameters.patch_size * (j - 1) + 1 : parameters.patch_size * j;
			
			mask_P = logical(zeros(size(mask)));
			mask_P(range_i, range_j) = imask(range_i, range_j);
			I_rec(mask_P) = P_rec(imask(range_i, range_j));
		end
	end
end
