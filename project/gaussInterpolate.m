% gaussInterpolate
% ================
% Interpolate an image using Gauss Filter
% Takes as input the Image, a mask and a parameters struct
function I_out = gaussInterpolate(I, mask, parameters)
  mask = double(mask);

  % Create filter
  h = fspecial('gaussian', parameters.gauss_size, parameters.gauss_sigma);
  I_masked = I .* mask;

  I_filtered = imfilter(I_masked, h, 'symmetric') ./ ...
               imfilter(mask, h, 'symmetric');
  I_out = (I_filtered .* (1-mask)) + (I_masked .* (mask));

  % Make sure we eliminate NaNs that may occur,
  % when gauss is too small and we have a large hole
  I_out(isnan(I_out)) = mean(mean(I(logical(mask))));
end
