function I_comp = Compress(I)

% Padding preparation
[h, w, c] = size(I);
N = 2^(ceil(log2(max(h,w))));

% Create image
image = zeros(N, N, c);
image(1:h, 1:w, :) = I;

% Haar transform
H = haarTrans(N);
for i=1:c
  transformed_image(:,:,c) = H'*image(:,:,c)*H;
end

% Thresholding
transformed_image(abs(transformed_image)<0.5) = 0;

I_comp.h = h;
I_comp.w = w;
I_comp.data = sparse(reshape(transformed_image, N, c*N));
