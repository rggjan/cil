% removeFrame
% ===========
% Removes the frame from an image, frame size specified in the
% parameters struct.
function I = removeFrame(I_framed, parameters)
  range = parameters.patch_frame_size + 1:size(I_framed, 1) - parameters.patch_frame_size;

  I = I_framed(range, range);
end
