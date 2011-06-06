function I_rec = InPainting(I, mask)

% Perform the actual inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hidding image information
%
% OUTPUT
% I_rec = Reconstructed image 

% Parameters
rc_min = 0.01; % rc_min: minimal residual correlation before stopping
neib = 32; % neib: The patch sizes used in the decomposition of the image
sigma = 0.01; % sigma: residual error stopping criterion, normalized by signal norm

patchsize=16; neighbourhood=8; t=88;

validation_percentage = 0.5;

% split into validation and test set
good_indices = find(mask);
num_good = length(good_indices);
perm = randperm(num_good);
val_indices = good_indices(perm(1:round(validation_percentage*num_good)));
val_mask = zeros(size(mask));
val_mask(val_indices) = 1;

I_copy = I;
I_copy(val_indices) = 0;

mask_copy = mask;
mask_copy(val_indices) = 0;

% Get patches of size neib x neib from the image and the mask and
% convert each patch to 1D signal
I_copy = gaussInterpolate(I_copy, mask_copy);
I_orig_gauss = gaussInterpolate(I, mask);
%I_rec = I;
%return;

% Create overlapping patches
numBlocks=size(I,1)/patchsize;

if(mod(size(I,1),patchsize)~=0)
  throw('Imagesize not multiple of pactchsize');
end

tic;

IG = zeros(size(I_copy,1)+2*neighbourhood, size(I_copy,1)+2*neighbourhood);
IG(neighbourhood+1 : neighbourhood+size(I,1), neighbourhood+1 : neighbourhood+size(I,1)) = I_copy;

IG_orig = zeros(size(I,1)+2*neighbourhood, size(I,1)+2*neighbourhood);
IG_orig(neighbourhood+1 : neighbourhood+size(I,1), neighbourhood+1 : neighbourhood+size(I,1)) = I_orig_gauss;

%Fill borders
for i=1:neighbourhood
  IG(:,i) = IG(:,neighbourhood+1);
  IG(:,end-i+1) = IG(:,end-neighbourhood);
  IG(i,:) = IG(neighbourhood+1,:);
  IG(end-i+1,:) = IG(end-neighbourhood,:);


  IG_orig(:,i) = IG_orig(:,neighbourhood+1);
  IG_orig(:,end-i+1) = IG_orig(:,end-neighbourhood);
  IG_orig(i,:) = IG_orig(neighbourhood+1,:);
  IG_orig(end-i+1,:) = IG_orig(end-neighbourhood,:);
end

% Create inverted mask (0=keep, 1=replace)
%mask = logical(1-mask);
for i=1:numBlocks
    for j=1:numBlocks
      % Get block from neighbourhooded picture
        block = IG( patchsize*(i-1)+1 : patchsize*i + 2*neighbourhood , patchsize*(j-1)+1:patchsize*j+2*neighbourhood);
        
        val_mask_block = val_mask(patchsize*(i-1)+1 : patchsize*i, patchsize*(j-1)+1:patchsize*j);
        ground_truth = I(patchsize*(i-1)+1 : patchsize*i, patchsize*(j-1)+1:patchsize*j).*val_mask_block;

        %figure(1);
        %imshow(block);
        
        best_error = Inf;
        best_block = 0;

        for perc=1:10
          F = fft2(block);
          F(abs(F) < perc) = 0;

          % Set reconstructed part to be inverse of FFT
          new_block = abs(ifft2(F));
          new_block_small = new_block(neighbourhood+1:patchsize+neighbourhood, neighbourhood+1:patchsize+neighbourhood);

          diff = (val_mask_block.*new_block_small - ground_truth);
          err = sum(sum(diff.*diff));
          %pause

          if (err < best_error)
            best_error = err;
            best_threshold = perc;
          end
        end
        %figure(1);
        %imshow(best_block);

        %pause
        
        %Extract inner part
        %Currentmask = logical(zeros(size(mask)));
        %Currentmask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j) = mask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j);

        block = IG_orig(patchsize*(i-1)+1 : patchsize*i + 2*neighbourhood , patchsize*(j-1)+1:patchsize*j+2*neighbourhood);

        F = fft2(block);
        F(abs(F) < best_threshold) = 0;

        % Set reconstructed part to be inverse of FFT
        new_block = abs(ifft2(F));
        new_block_small = new_block(neighbourhood+1:patchsize+neighbourhood, neighbourhood+1:patchsize+neighbourhood);

        I_copy(patchsize*(i-1)+1 : patchsize*i, patchsize*(j-1)+1:patchsize*j) = new_block_small;
        
        %I_copy(Currentmask) = best_block(mask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j));

        %figure(2);
        %imshow(I_copy);
        %pause;
        
    end
end


toc;

% You need to do the image reconstruction using the known image information
% and for the missing pixels use the reconstruction from the sparse coding.
% The mask will help you to distinguish between these two parts.
%I_rec = my_col2im(Z, neib, size(I, 1));
%I_rec = I.*mask + I_copy.*(1-mask);
I_rec = I_copy;
