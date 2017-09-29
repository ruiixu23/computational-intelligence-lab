% This function extract horizontal half-overlapping patches from an image and
% vectorize them.
%
% Input
%   img: the input image to be verctorized
%   patch_size: size of the patch
%
% Output
%   patches: the vectorized image with half overlapping patches
function patches = halfHorizontalOverlappingPatches(img, patch_size)
    patches = zeros(patch_size * patch_size, (size(img, 1) / patch_size) * ((size(img, 2) - patch_size) / (patch_size / 2) + 1));

    patch_idx = 1;
    for patch_row_start = 1:patch_size:size(img, 1)
        for patch_column_start = 1:(patch_size / 2):(size(img, 2) - patch_size / 2)
            patch = img(patch_row_start: patch_row_start + patch_size - 1, patch_column_start: patch_column_start + patch_size - 1);
            patches(:, patch_idx) = patch(:);
            patch_idx = patch_idx + 1;
        end
    end
end