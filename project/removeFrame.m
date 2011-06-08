function I = removeFrame(I_framed, parameters)
  range = parameters.patch_frame_size + 1: ...
          end -  parameters.patch_frame_size;

  I = I_framed(range, range);
end
