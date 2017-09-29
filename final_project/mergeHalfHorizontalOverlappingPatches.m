% This function merges verctorized half-overlapping patches from an image and
% returns the merged image.
%
% Input
%   overlapping_patches: the input patches to be merged
%   patch_size: size of the patch
%   img_size: size of the merged image
%
% Output
%   img: the merged image
function img = mergeHalfHorizontalOverlappingPatches(overlapping_patches, patch_size, img_size)
    num_overlapping_patches_row = (img_size - patch_size) / (patch_size / 2) + 1;
    num_patches_per_row = img_size / patch_size;
    num_patches_per_column = img_size / patch_size;
    upper_half_patch_start = 1;
	upper_half_patch_end = patch_size * patch_size / 2;
	lower_half_patch_start = patch_size * patch_size / 2 + 1;
	lower_half_patch_end = patch_size * patch_size;

    patches_merged = zeros(patch_size * patch_size, (img_size * img_size) / (patch_size * patch_size));

    for patch_row_idx = 1:num_patches_per_column
        base = (patch_row_idx - 1) * num_overlapping_patches_row;
        patch_row = zeros(patch_size * patch_size, num_patches_per_row);
        patch_column_idx = 1;

        for overlapping_patch_column_idx = 1:2:num_overlapping_patches_row
            patch_row(:,patch_column_idx) = overlapping_patches(:, base + overlapping_patch_column_idx);
            patch_column_idx = patch_column_idx + 1;
        end

        %  Upper overlap
        patch_row_overlap_upper = zeros(patch_size * patch_size / 2, num_patches_per_row);
        patch_row_overlap_upper(:, 1) = patch_row(upper_half_patch_start:upper_half_patch_end, 1);
        patch_column_idx = 2;
        for overlapping_patch_column_idx = 2:2:num_overlapping_patches_row
            patch_row_overlap_upper(:, patch_column_idx) = overlapping_patches(lower_half_patch_start:lower_half_patch_end, base + overlapping_patch_column_idx);
            patch_column_idx = patch_column_idx + 1;
        end

        % Lower overlap
        patch_row_overlap_lower = zeros(patch_size * patch_size / 2, num_patches_per_row);
        patch_row_overlap_lower(:, end) = patch_row(lower_half_patch_start: lower_half_patch_end, end);
        patch_column_idx = 1;
        for overlapping_patch_column_idx = 2:2:num_overlapping_patches_row
            patch_row_overlap_lower(:, patch_column_idx) = overlapping_patches(upper_half_patch_start:upper_half_patch_end, base + overlapping_patch_column_idx);
            patch_column_idx = patch_column_idx + 1;
        end

        patch_row_merged = (patch_row + [patch_row_overlap_upper; patch_row_overlap_lower]) / 2;
        for patch_column_idx = 1:size(patch_row_merged, 2)
            patches_merged(:, (patch_column_idx - 1) * num_patches_per_column + patch_row_idx) = patch_row_merged(:, patch_column_idx);
        end
    end

    img = col2im(patches_merged, [patch_size patch_size], [img_size img_size], 'distinct');
end