function I_rec = Decompress(I_comp)
  I_rec = I_comp.Uk*I_comp.Z + repmat(I_comp.mu, 1, size(I_comp.Z, 2));

  dims = size(I_rec)
  d = sqrt(dims(1))

  I_rec = reshape(I_rec, d, []);
end
