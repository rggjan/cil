function [ I_corrected ] = boundImageValues( I )
%BOUNDIMAGEVALUES Bounds image values to the [0,1] domain
%   Makes sure that an image contains only values in the [0,1] domain.
%   Values outside this range will be set to the nearer boundary

I_corrected = I;
I_corrected(I>1) = 1;
I_corrected(I<0) = 0;

end

