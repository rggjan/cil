function Iout = inPainting(I, mask)

I = I .* mask;

% Perform the actual inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hidding image information
%
% OUTPUT
% I_rec = Reconstructed image 

radius = 1;
[height, width] = size(I);

border_I = zeros(height+2*radius, width+2*radius);
border_I((1+radius):(radius+height), (1+radius):(radius+width)) = I;

for x = (1+radius):(radius+width)
  for y = (1+radius):(radius+height)
    border_I(x,y) = 1-border_I(x,y);
  end
end

Iout = border_I((1+radius):(radius+height), (1+radius):(radius+width));
