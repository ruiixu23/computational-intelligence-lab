% This function generates new textual masks based on the given mask image
% mask.png. It shuffles patches of the original mask around. The size of
% the patch is specified by the input patch_size
% Input:
%   patch_size      Size of patches to be shuffled around
function mask = generateMask(patch_size)
    mask = imread('mask.png');
    num_patches_per_row = size(mask, 1) / patch_size;
    num_patches_per_column = size(mask, 2) / patch_size;

    for row_start = 1:patch_size:size(mask, 1)
        row_end = row_start + patch_size - 1;
        for column_start = 1:patch_size:size(mask, 2)
            column_end = column_start + patch_size - 1;

            exchange_row_start = (randi(num_patches_per_row) - 1) * patch_size + 1;
            exchange_row_end = exchange_row_start + patch_size - 1;
            exchange_column_start = (randi(num_patches_per_column) - 1) * patch_size + 1;
            exchange_column_end = exchange_column_start + patch_size - 1;

            patch = mask(row_start:row_end, column_start:column_end);
            mask(row_start:row_end, column_start:column_end) = ...
                mask(exchange_row_start:exchange_row_end, ...
                exchange_column_start:exchange_column_end);
            mask(exchange_row_start:exchange_row_end, ...
                exchange_column_start:exchange_column_end) = patch;
        end
    end
end