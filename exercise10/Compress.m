function I_comp = Compress(I)

% Padding preparation
[h, w, C] = size(I);
N = 2^(ceil(log2(max(h,w))));

% Create image
image = zeros(N, N, C);
image(1:h, 1:w, :) = I;

% Haar transform
H = haarTrans(N);
for c=1:C
  transformed_image(:,:,c) = H'*image(:,:,c)*H;
end

% Thresholding
abs_image = abs(transformed_image);
t = mean(transformed_image(:));
v = var(transformed_image(:));
transformed_image(abs_image<t+2*v) = 0;

I_comp.h = h;
I_comp.w = w;
I_comp.data = sparse(reshape(transformed_image, N, c*N));
