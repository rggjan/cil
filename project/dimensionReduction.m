function I_reduced = dimensionReduction(I, T, parameters)

pfs = parameters.patch_frame_size;
ps = parameters.patch_size;

image_size = size(I, 1);
num_patches = (image_size-2*pfs) / ps;
I_reduced = I;

for i = 1 : num_patches
  for j = 1 : num_patches
    P_framed = I(ps * (i - 1) + 1 : ...
                 ps * i + 2 * pfs, ...
		 ps * (j - 1) + 1 : ...
                 ps * j + 2 * pfs);

    P_fft = fft2(P_framed);
    P_abs = abs(P_fft);
		  
    P_fft(abs(P_fft) < T(i, j)) = 0;
    P_ifft = abs(ifft2(P_fft));
		
    P_rec = removeFrame(P_ifft, parameters);    
			
    range_i = pfs + ps*(i-1) + 1 : pfs + ps * i;
    range_j = pfs + ps*(j-1) + 1 : pfs + ps * j;
    I_reduced(range_i, range_j) = P_rec;
  end
end

end
