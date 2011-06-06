function I_out = gaussInterpolate(I, mask)

mask = double(mask);

sigma = 0.8;
gauss_size = 5;

h = fspecial('gaussian', gauss_size, sigma);
I_masked = I.*mask;

I_filtered = imfilter(I_masked, h, 'replicate')./imfilter(mask, h, 'replicate');
I_out = (I_filtered.*(1-mask))+(I_masked.*(mask));
