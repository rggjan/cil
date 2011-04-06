function I_rec = Decompress(I_comp)

% Your decompression code goes here!
[height,width] = size(I_comp.X);
I_rec = zeros(height,width,size(I_comp.U,1));

for r = 1:height
  for c = 1:width
    I_rec(r,c,:) = reshape(I_comp.U(I_comp.X(r,c)),1,1,[]);
  end
end

%for i=1:size(I_comp.U,2)
%  i
%  I_rec(find(I_comp.X == i),:) = I_comp.U(i);
%end
