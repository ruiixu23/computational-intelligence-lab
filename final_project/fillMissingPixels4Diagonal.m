% This function fills the missing pixels in an image by averaging the
% non-missing pixels surrounding it. It first uses diagonal distance 1 to find
% non-missing pixels. If they is none, it checks surrounding pixels at distance
% 2 and so on. Finally, it stops at distance specified by the parameter
% `max_distance`. A value of 0.5 will be used to fill the missing pixels if all
% surrounding pixels of distance up to `max_distance` are all missing.
%
% Input:
%   img: the image with missing pixels to be filled
%   msk: the mask of the image with 0's indicating missing pixels
%   max_dist: maximum checking distance of surrounding pixels
%
% Output:
%   img_filled: the image with missing pixels filled

function img_filled = fillMissingPixels4Diagonal(img, msk, max_dist)
    [img_height, img_width] = size(img);
    img_padded_height = img_height + 2 * max_dist;
    img_padded_width = img_width + 2 * max_dist;

    % Real start point of the image in the padded image
    img_padded_row_start = 1 + max_dist;
    img_padded_row_end = img_padded_row_start + img_height - 1;
    img_padded_col_start = 1 + max_dist;
    img_padded_col_end = img_padded_col_start + img_width - 1;

    % Add zero paddings to image
    img_padded = zeros(img_padded_height, img_padded_width);
    img_padded(img_padded_row_start: img_padded_row_end, ...
        img_padded_col_start: img_padded_col_end) = img;

    % Add ones paddings to mask
    msk_padded = ones(img_padded_height, img_padded_width);
    msk_padded(img_padded_row_start: img_padded_row_end, ...
        img_padded_col_start: img_padded_col_end) = msk;

    % Prefill missing pixels with default value 0.5
    missing_pixels_idx = find(msk_padded == 0);
    img_filled_padded = img_padded;
    img_filled_padded(missing_pixels_idx) = 0.5;

    % Add zero paddings to mask
    msk_padded = zeros(img_padded_height, img_padded_width);
    msk_padded(img_padded_row_start: img_padded_row_end, ...
        img_padded_col_start: img_padded_col_end) = msk;

%     % Initialize neighbour indices
%     neighbours = cell(1, max_dist);
%     for dist = 1:max_dist
%         neighbours{1, dist} = [(dist + dist * img_padded_height) ...
%             (-1 * dist + dist * img_padded_height) ...
%             (dist - 1 * dist * img_padded_height) ...
%             (-1 * dist - 1 * dist * img_padded_height)];
%     end

    for i = 1:numel(missing_pixels_idx)
        idx = missing_pixels_idx(i);
        for dist = 1:max_dist
%             neighbour_pixels_idx = idx + neighbours{1, dist};
            neighbour_pixels_idx = [(dist + dist * img_padded_height + idx) ...
                (-1 * dist + dist * img_padded_height + idx) ...
                (dist - 1 * dist * img_padded_height + idx) ...
                (-1 * dist - 1 * dist * img_padded_height + idx)];
            nnz_count = 0;
            total = 0.0;
            for j = 1:numel(neighbour_pixels_idx)
                nnz_count = nnz_count + msk_padded(neighbour_pixels_idx(j));
                total = total + img_padded(neighbour_pixels_idx(j));
            end
            if (nnz_count > 0)
                img_filled_padded(idx) = total / nnz_count;
                break;
            end
        end
    end

    img_filled = img_filled_padded(img_padded_row_start: img_padded_row_end, ...
        img_padded_col_start: img_padded_col_end);
end