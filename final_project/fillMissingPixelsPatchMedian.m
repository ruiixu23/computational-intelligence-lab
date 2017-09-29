% This function fills the missing pixels in an image by averaging the
% non-missing pixels surrounding it. It first divide each pixel into
% non-overlapping patches of width specified by the parameter `patch_size`.
% Then it check if there is any non-missing pixel in that patch. If there
% is, every missing pixels in that patch is fill with the median value of the
% non-missing pixels. Note that a value of 0.5 will be used to fill the missing
% pixels if all surrounding pixels are all missing.
%
% Input:
%   img: the image with missing pixels to be filled
%   msk: the mask of the image with 0's indicating missing pixels
%   patch_size: size of patch
%
% Output:
%   img_filled: the image with missing pixels filled
function img_filled = fillMissingPixelsPatchMedian(img, msk, patch_size)
    img_filled = img;

    % Prefill missing pixels with default value 0.5
    img_filled(~msk) = 0.5;

    for patch_row_start = 1:patch_size:size(img, 1)
        for patch_column_start = 1:patch_size:size(img, 2)
            patch_row_end = patch_row_start + patch_size - 1;
            patch_column_end = patch_column_start + patch_size - 1;

            patch = img(patch_row_start: patch_row_end, patch_column_start: patch_column_end);
            patch_msk = msk(patch_row_start:patch_row_end, patch_column_start: patch_column_end);

            non_missing_pixels_idx = find(patch_msk ~= 0);
            nnz_count =  numel(non_missing_pixels_idx);
            if (nnz_count > 0 && nnz_count < patch_size * patch_size)
                patch(~patch_msk) = median( patch(non_missing_pixels_idx));
                img_filled(patch_row_start:patch_row_end, patch_column_start: patch_column_end) = patch;
            end
        end
    end
end