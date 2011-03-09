function out = Decompress(I_comp)
  I_rec = I_comp.Uk*I_comp.Z + repmat(I_comp.mu, 1, size(I_comp.Z, 2));

  d = I_comp.d;
  
  row=1;
  column=1;

  for i=1:size(I_rec,2)/3
      block_r = reshape(I_rec(:,i)  , I_comp.d, I_comp.d);
      block_g = reshape(I_rec(:,i+size(I_rec,2)/3), I_comp.d, I_comp.d);
      block_b = reshape(I_rec(:,i+2*size(I_rec,2)/3), I_comp.d, I_comp.d);
      red(  (row-1)*d+1:row*d, (column-1)*d+1:column*d) = block_r;
      green((row-1)*d+1:row*d, (column-1)*d+1:column*d) = block_g;
      blue( (row-1)*d+1:row*d, (column-1)*d+1:column*d) = block_b;
      
      if(I_comp.numColumnBlocks == column)
         column=1;
         row=row+1;
      else
         column=column+1;
      end

  end

  out(:,:,1) = red;
  out(:,:,2) = green;
  out(:,:,3) = blue;
  
  imshow(out(1:size(out,1)-I_comp.extendedX, 1:size(out,2)-I_comp.extendedY, :));
  
end
