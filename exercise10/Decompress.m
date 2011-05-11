function I_rec = Decompress(I_comp)

N = size(I_comp.data, 1);

H = haarTrans(N);
I_rec = H*I_comp.data*H';

I_rec = I_rec(1:I_comp.h, 1:I_comp.w);
