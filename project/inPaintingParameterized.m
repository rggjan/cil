function I_rec = inPaintingParameterized(I, mask, parameters)

% Perform the actual inpainting of the image.

% INPUT
% I: Masked image (n x n)
% mask: Mask itself (n x n)
% parameters: Parameters (as an object)
%
% OUTPUT
% I_rec: Reconstructed image 

% Interpolate the missing pixels with Gaussian weighting.
I_rec = gaussInterpolate(I, mask, parameters);

% Frame the original image by duplicating the first and last row respectively column.
if mod(size(I, 1), parameters.patch_size) ~= 0
	throw('The patch size does not divide the image size!');
end

num_patches = size(I, 1) / parameters.patch_size;
num_pixels = size(I, 1) + 2 * parameters.frame;

I_framed = zeros(num_pixels, num_pixels);
I_framed(parameters.frame + 1 : parameters.frame + size(I, 1), parameters.frame + 1 : parameters.frame + size(I, 1)) = I;

for i = 1 : parameters.frame
	I_framed(:, i) = I_framed(:, parameters.frame + 1);
	I_framed(:, end - i + 1) = I_framed(:, end - parameters.frame);
	I_framed(i, :) = I_framed(parameters.frame + 1, :);
	I_framed(end - i + 1, :) = I_framed(end - parameters.frame, :);
end

% Invert the mask (0 = keep, 1 = replace)
mask = logical(1 - mask);

% Repeat the dimension reduction in the Fourier domain k times.
for k = 1 : parameters.iterations
	for i = 1 : num_patches
		for j = 1 : num_patches
			P_framed = I_framed(parameters.patch_size * (i - 1) + 1 : parameters.patch_size * i + 2 * parameters.frame, ...
					parameters.patch_size * (j - 1) + 1 : parameters.patch_size * j + 2 * parameters.frame);
			P_fft = fft2(P_framed);
			P_abs = abs(P_fft);
			
			% perc = prctile(reshape(P_abs, 1, []), parameters.percentile);
			perc = 1;
			P_fft(abs(P_fft) < perc) = 0;
			P_ifft = abs(ifft2(P_fft));
			
			P_rec = P_ifft(parameters.frame + 1 : end - parameters.frame, parameters.frame + 1 : end - parameters.frame);
			
			range_i = parameters.patch_size * (i - 1) + 1 : parameters.patch_size * i;
			range_j = parameters.patch_size * (j - 1) + 1 : parameters.patch_size * j;
			
			mask_P = logical(zeros(size(mask)));
			mask_P(range_i, range_j) = mask(range_i, range_j);
			I_rec(mask_P) = P(mask(range_i, range_j));
		end
	end
end
