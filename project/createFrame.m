function I_framed = createFrame(I, parameters)
  image_size = size(I, 1);

  I_framed = zeros(image_size + 2*parameters.patch_frame_size);

  % Frame the image by duplicating the first and last row respectively column.
  I_framed(parameters.patch_frame_size + 1 : parameters.patch_frame_size + image_size, ...
           parameters.patch_frame_size + 1 : parameters.patch_frame_size + image_size) = I;
  
  for i = 1 : parameters.patch_frame_size
    % TODO optimize, use repmat
    I_framed(:, i) = I_framed(:, parameters.patch_frame_size + 1);
    I_framed(:, end - i + 1) = I_framed(:, end - parameters.patch_frame_size);
    I_framed(i, :) = I_framed(parameters.patch_frame_size + 1, :);
    I_framed(end - i + 1, :) = I_framed(end - parameters.patch_frame_size, :);
  end
end
