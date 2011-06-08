function I_reduced = dimensionReduction(I, T, parameters)

image_size = size(I, 1);
num_patches = (image_size-2*parameters.patch_frame_size) / parameters.patch_size;
I_reduced = I;

for i = 1 : num_patches
  for j = 1 : num_patches
    P_framed = I(parameters.patch_size * (i - 1) + 1 : ...
                 parameters.patch_size * i + 2 * parameters.patch_frame_size, ...
		 parameters.patch_size * (j - 1) + 1 : ...
                 parameters.patch_size * j + 2 * parameters.patch_frame_size);

    P_fft = fft2(P_framed);
    P_abs = abs(P_fft);
		  
    P_fft(abs(P_fft) < T(i, j)) = 0;
    P_ifft = abs(ifft2(P_fft));
		
    P_rec = removeFrame(P_ifft, parameters);    
			
    range_i = parameters.patch_size * (i-1) + 1 : parameters.patch_size * i;
    range_j = parameters.patch_size * (j-1) + 1 : parameters.patch_size * j;    
    I_reduced(range_i, range_j) = P_rec;
  end
end

end
