% This function fills the missing pixels in an image with the fixed value
% specified by the parameter `value`.
%
% Input:
%   img: the image with missing pixels to be filled
%   msk: the mask of the image with 0's indicating missing pixels
%   value: value used to fill the missing pixels
%
% Output:
%   img_filled: the image with missing pixels filled
function img_filled = fillMissingPixelsFixed(img, msk, value)
    img_filled = img;
    img_filled(~msk) = value;
end