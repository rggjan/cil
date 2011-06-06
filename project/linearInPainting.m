function I_rec = linearInPainting(I, mask)

% Perform the actual inpainting of the image 

% INPUT
% I: (n x n) masked image
% mask: (n x n) the mask hidding image information
%
% OUTPUT
% I_rec = Reconstructed image 

global U;

% Parameters
rc_min = 0.01; % rc_min: minimal residual correlation before stopping
neib = 32; % neib: The patch sizes used in the decomposition of the image
sigma = 0.01; % sigma: residual error stopping criterion, normalized by signal norm

patchsize=16; neighbourhood=8; t=88;


% Get patches of size neib x neib from the image and the mask and
% convert each patch to 1D signal

[w, h] = size(I);

for x=1:w
  for y=1:h
    if mask(x, y) == 0
      values = 0;
      s = 0;

      for (i=1:10)
        try
          if mask(x+i, y) ~= 0
            values = values + I(x+i, y)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for (i=1:10)
        try
          if mask(x, y+i) ~= 0
            values = values + I(x, y+i)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for (i=1:10)
        try
          if mask(x, y-i) ~= 0
            values = values + I(x, y-i)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      for (i=1:10)
        try
          if mask(x-i, y) ~= 0
            values = values + I(x-i, y)/i;
            s = s + 1/i;
            break;
          end
        catch
          break;
        end
      end

      I(x, y) = values / s;
    end
  end
end

% Create overlapping patches
numBlocks=size(I,1)/patchsize;

if(mod(size(I,1),patchsize)~=0)
  throw('Imagesize not multiple of pactchsize');
end

tic;

IG = zeros(size(I,1)+2*neighbourhood, size(I,1)+2*neighbourhood);
IG(neighbourhood+1 : neighbourhood+size(I,1), neighbourhood+1 : neighbourhood+size(I,1)) = I;

%Fill borders
for i=1:neighbourhood
  IG(:,i) = IG(:,neighbourhood+1);
  IG(:,end-i+1) = IG(:,end-neighbourhood);
  IG(i,:) = IG(neighbourhood+1,:);
  IG(end-i+1,:) = IG(end-neighbourhood,:);
end

% Create inverted mask (0=keep, 1=replace)
mask = logical(1-mask);
for i=1:numBlocks
    for j=1:numBlocks
      % Get block from neighbourhooded picture
        block = IG( patchsize*(i-1)+1 : patchsize*i + 2*neighbourhood , patchsize*(j-1)+1:patchsize*j+2*neighbourhood);
        F = fft2(block);
        T = abs(F);
        perc = prctile(reshape(T,1,[]),t);
        F(abs(F) < perc) = 0;
        % Set reconstructed part to be inverse of FFT
        Whole = abs(ifft2(F));
        
        %Extract inner part
        Inner = Whole(neighbourhood+1:end-neighbourhood, neighbourhood+1:end-neighbourhood);
        
        Currentmask = logical(zeros(size(mask)));
        Currentmask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j) = mask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j);

        
        I(Currentmask) = Inner(mask(patchsize*(i-1)+1 : patchsize*i , patchsize*(j-1)+1 : patchsize*j));
        
    end
end


toc;
    

% You need to do the image reconstruction using the known image information
% and for the missing pixels use the reconstruction from the sparse coding.
% The mask will help you to distinguish between these two parts.
%I_rec = my_col2im(Z, neib, size(I, 1));
I_rec = I;
