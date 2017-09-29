function rec_patches = removeNan(rec_patches, nan_indices, num_patches_row, num_rows, neib)
    for index = nan_indices
        row = ceil(index / num_patches_row);
        column = mod(index, num_patches_row);
        if (column == 0)
            column = num_patches_row;
        end

        result = [0 0];
        if (row > 1)
            % Top left
            neighbour_row = row - 1;
            if (column > 1)
                neighbour_column = column - 1;
                result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
            end

            % Top
            neighbour_column = column;
            result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);

            % Top right
            if (column < num_patches_row)
                neighbour_column = column + 1;
                result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
            end
        end

        % Left
        neighbour_row = row;
        if (column > 1)
            neighbour_column = column - 1;
            result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
        end

        % Right
        neighbour_row = row;
        if (column < num_patches_row)
            neighbour_column = column + 1;
            result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
        end

        if (row < num_rows)
            % Bottom left
            neighbour_row = row - 1;
            if (column > 1)
                neighbour_column = column - 1;
                result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
            end

            % Bottom
            neighbour_column = column;
            result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);

            % Bottom right
            if (column < num_patches_row)
                neighbour_column = column + 1;
                result = result + getNeighbourSum(rec_patches, neighbour_row, neighbour_column, num_patches_row);
            end
        end

        if (result(1) == 0)
            rec_patches(:, index) = zeros(neib * neib, 1) + 0.5;
        else
            rec_patches(:, index) = zeros(neib * neib, 1) + result(1) / result(2);
        end
    end
end

function result = getNeighbourSum(rec_patches, row, column, num_patches_row)
    total = 0;
    count = 0;
    index = row * num_patches_row + column;
    if (~isnan(rec_patches(index)))
        total = sum(rec_patches(index));
        count = size(rec_patches, 1);
    end

    result = [total count];
end