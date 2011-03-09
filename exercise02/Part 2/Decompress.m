function out = Decompress(I_comp)
  I_rec = I_comp.Uk*I_comp.Z + repmat(I_comp.mu, 1, size(I_comp.Z, 2));

  d = I_comp.d;
  
  row=1;
  column=1;

  for i=1:size(I_rec,2)/3
    for c=1:I_comp.color_channels
      out( (row-1)*d+1:row*d, (column-1)*d+1:column*d, c) = reshape(I_rec(:,i + (c-1)*size(I_rec,2)/3), I_comp.d, I_comp.d);
    end
      
      if(I_comp.numColumnBlocks == column)
         column=1;
         row=row+1;
      else
         column=column+1;
      end

  end
  
  %Cutting off excess lines/columns
  out = out(1:size(out,1)-I_comp.extendedX, 1:size(out,2)-I_comp.extendedY, :);
  
end
