% createFrame
% ===========
% Create a frame around the image.
% Size of the frame depending on the parameters. The frame is a mirrored
% version of the outermost rows/columns.

function I_framed = createFrame(I, parameters)
  image_size = size(I, 1);

  % Create a bigger image, with zeros as borders
  I_framed = zeros(image_size + 2*parameters.patch_frame_size);
  I_framed(parameters.patch_frame_size + 1 : parameters.patch_frame_size + image_size, ...
           parameters.patch_frame_size + 1 : parameters.patch_frame_size + image_size) = I;
  
  % Fill the borders with the mirrored pixels
  for i = 1 : parameters.patch_frame_size
    I_framed(:, i) = I_framed(:, 2*parameters.patch_frame_size - i+1);
    I_framed(:, end - i + 1) = I_framed(:, end - 2*parameters.patch_frame_size + i);
    I_framed(i, :) = I_framed(2*parameters.patch_frame_size - i+1, :);
    I_framed(end - i + 1, :) = I_framed(end - 2*parameters.patch_frame_size + i, :);
  end
end
