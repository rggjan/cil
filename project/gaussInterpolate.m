function I_out = gaussInterpolate(I, mask, parameters)

mask = double(mask);

h = fspecial('gaussian', parameters.gauss_size, parameters.gauss_sigma);
I_masked = I .* mask;

I_filtered = imfilter(I_masked, h, 'replicate') ./ ...
             imfilter(mask, h, 'replicate');
I_out = (I_filtered .* (1-mask)) + (I_masked .* (mask));
