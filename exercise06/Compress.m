function I_comp = Compress(I)

[height, width, colors] = size(I);

X = reshape(I, [], colors);

[z, U, loglike] = gmm(X', 256);

% TODO U in smaller datatype

I_comp.X = uint8(reshape(z, height, width));
