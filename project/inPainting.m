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
total = height * width;

border_I = zeros(height+2*radius, width+2*radius);
border_I((1+radius):(radius+height), (1+radius):(radius+width)) = I;

border_mask = zeros(height+2*radius, width+2*radius);
border_mask((1+radius):(radius+height), (1+radius):(radius+width)) = mask;

X = zeros(8, total);
maskX = zeros(8, total);

counter = 1
for x = (1+radius):(radius+width)
  for y = (1+radius):(radius+height)
    X(1, counter) = border_I(y+1, x+1);
    X(2, counter) = border_I(y  , x+1);
    X(3, counter) = border_I(y-1, x+1);
    X(4, counter) = border_I(y+1, x  );
    X(5, counter) = border_I(y-1, x  );
    X(6, counter) = border_I(y+1, x-1);
    X(7, counter) = border_I(y  , x-1);
    X(8, counter) = border_I(y-1, x-1);

    maskX(1, counter) = border_mask(y+1, x+1);
    maskX(2, counter) = border_mask(y  , x+1);
    maskX(3, counter) = border_mask(y-1, x+1);
    maskX(4, counter) = border_mask(y+1, x  );
    maskX(5, counter) = border_mask(y-1, x  );
    maskX(6, counter) = border_mask(y+1, x-1);
    maskX(7, counter) = border_mask(y  , x-1);
    maskX(8, counter) = border_mask(y-1, x-1);

    xsum=sum(X(:, counter));
    masksum=sum(maskX(:, counter));
    average = sum(X(:, counter))/sum(maskX(:, counter));
    border_I(x,y) = average;
    counter = counter + 1;
  end
end

Iout = border_I((1+radius):(radius+height), (1+radius):(radius+width));
