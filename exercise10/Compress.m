function I_comp = Compress(I)

% Padding preparation
[h, w] = size(I);
N = 2^(ceil(log2(max(h,w))));

% Create image
image = zeros(N, N);
image(1:h, 1:w) = I;

% Haar transform
H = haarTrans(N);
transformed_image = H'*image*H;

% Thresholding
transformed_image(abs(transformed_image)<0.5) = 0;

I_comp.h = h;
I_comp.w = w;
I_comp.data = sparse(transformed_image);
