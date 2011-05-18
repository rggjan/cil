function mask = random_mask(size,missing)

% function mask = random_mask(size,missing)
% Returns a binary mask of requested size with missing per cent of pixels

sel = randperm(size^2);
mask = true(size);
mask(sel(1:round(missing*end))) = false;
        
        
        
        