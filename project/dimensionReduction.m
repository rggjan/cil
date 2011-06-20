function I_reduced = dimensionReduction(I, T, parameters)
% DIMENSIONREDUCTION Reduces dimension in Fourier space with threshold T

pfs = parameters.patch_frame_size;
ps = parameters.patch_size;

image_size = size(I, 1);
num_patches = (image_size-2*pfs) / ps;
I_reduced = I;

% Iterate over all patches
for i = 1 : num_patches
  for j = 1 : num_patches
    % Extract patch
    P_framed = I(ps * (i - 1) + 1 : ...
                 ps * i + 2 * pfs, ...
		 ps * (j - 1) + 1 : ...
                 ps * j + 2 * pfs);

    % To fourier domain
    P_fft = fft2(P_framed);
  
    % Thresholding, then back to spatial domain
    P_fft(abs(P_fft) < T(i, j)) = 0;
    P_ifft = ifft2(P_fft);

    % Make sure we do not fall outside the value range of an image
    P_rec = removeFrame(P_ifft, parameters);

    range_i = pfs + ps*(i-1) + 1 : pfs + ps * i;
    range_j = pfs + ps*(j-1) + 1 : pfs + ps * j;
    I_reduced(range_i, range_j) = P_rec;
  end
end

end
