function Iout = inPainting(I, mask)

I = I .* mask;

% Perform the actual inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hiding image information
%
% OUTPUT
% I_rec = Reconstructed image 

radius = 1;
[height, width] = size(I);
total = height * width;

border_I = zeros(height+2*radius, width+2*radius);
border_I((1+radius):(radius+height), (1+radius):(radius+width)) = I;
border_out = border_I;

border_mask = zeros(height+2*radius, width+2*radius);
border_mask((1+radius):(radius+height), (1+radius):(radius+width)) = mask;

tile_size = (radius*2+1)*(radius*2+1);

X = zeros(tile_size, total*tile_size);
maskX = zeros(tile_size, total*tile_size);

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
   
    for p = 1:(tile_size-1)
      X(:, counter+p) = circshift(X(:, counter), p);
      maskX(:, counter+p) = circshift(maskX(:, counter), p);
    end
    
    counter = counter + tile_size;
  end
end

[z, U, score] = k_means(X, maskX, 50);

counter = 1;
for x = (1+radius):(radius+width)
  for y = (1+radius):(radius+height)
    %if (~border_mask(y, x))
    %  average = sum(X(:, counter))/sum(maskX(:, counter));
     % border_out(y,x) = average;
    %end

%    if (~border_mask(y, x))
      my_clusters = U(:, z(counter:(counter+tile_size-1)));
      my_cluster = sum(my_clusters,2) / tile_size;

      border_out(y, x) = my_cluster(floor(tile_size/2+1));
%    end

    counter = counter + tile_size;
  end
end

Iout = border_out((1+radius):(radius+height), (1+radius):(radius+width));
