function I_rec = Decompress(I_comp)

[N, N3] = size(I_comp.data);
C = N3/N;

data = reshape(full(I_comp.data), N, N, C);

H = haarTrans(N);

for c=1:C
  I_rec(:,:,c) = H*data(:,:,c)*H';
end

I_rec = I_rec(1:I_comp.h, 1:I_comp.w, :);
