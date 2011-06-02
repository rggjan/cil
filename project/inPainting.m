function Iout = inPainting(I, mask)

I = I .* mask;

% Perform the actual inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hiding image information
%
% OUTPUT
% I_rec = Reconstructed image 

radius = 2;
[height, width] = size(I);
total = height * width;

border_I = zeros(height+2*radius, width+2*radius);
border_I((1+radius):(radius+height), (1+radius):(radius+width)) = I;
border_out = border_I;

border_mask = zeros(height+2*radius, width+2*radius);
border_mask((1+radius):(radius+height), (1+radius):(radius+width)) = mask;

tile_size = (radius*2+1)*(radius*2+1);

X = zeros(tile_size, total);
maskX = zeros(tile_size, total);

counter = 1;
for x = (1+radius):(radius+width)
  for y = (1+radius):(radius+height)
    small_counter = 1;

    for xdiff = -radius:radius
      for ydiff = -radius:radius
        X(small_counter, counter) = border_I(y+ydiff, x+xdiff);
        maskX(small_counter, counter) = border_mask(y+ydiff, x+xdiff);
        small_counter = small_counter + 1;
      end
    end
    
    counter = counter + 1;
  end
end

[z, U, score] = k_means(X, maskX, 20);

counter = 1;
for x = (1+radius):(radius+width)
  for y = (1+radius):(radius+height)
    %if (~border_mask(y, x))
    %  average = sum(X(:, counter))/sum(maskX(:, counter));
     % border_out(y,x) = average;
    %end

%    if (~border_mask(y, x))
      my_cluster = U(:, z(counter));

      border_out(y, x) = my_cluster(floor(tile_size/2+1));
%    end

    counter = counter + 1;
  end
end

Iout = border_out((1+radius):(radius+height), (1+radius):(radius+width));
