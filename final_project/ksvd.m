% Perform the K-SVD dictionary learning algorithm
%
% Input
%   patches: observations
%   num_atoms: number of dictionary atoms
%
% Output
%   dict: the learned dictionary
function dict = ksvd(patches, num_atoms)
    max_iters = 100;

    [patch_size, ~] = size(patches);

    % Subtract means already in data matrix to find column entirely filled
    % with same value
    patches = patches - repmat(mean(patches), patch_size, 1);

    % Remove columns of patches_reduced entirely filled of zeros
    patches(:, ~any(patches, 1)) = [];

    % Update size
    [~, num_patches] = size(patches);

    % Initialize dictionary with random data pathces
    idx = randsample(num_patches, num_atoms);
    dict = patches(:, idx);
    dict = dict ./ repmat(sqrt(sum(dict .^ 2)), patch_size, 1);

    % Set first element to be constant, it is the only one with non-zero mean
    dict(:, 1) = ones(patch_size, 1);
    dict(:, 1) = dict(:, 1) / patch_size;

    % Initialize dictionary with DCT
%   dict = overDCTdict(patch_size, num_atoms);

    % K-SVD loop
    for iter = 1:max_iters
        disp(['Iteration: ', num2str(iter)]);

        % Sparse coding assuming fixed dictionary
        coeff = sparseCoding(dict, patches, 0.01, 0.01);

        % Update dictionary and coefficient
        for atom_idx = 2:num_atoms
            % Consider only nonzero elements
            coeff_m = coeff;
            coeff_m(atom_idx, :) = 0;
            non_zero_idx = coeff(atom_idx, :) ~= 0;

            % Update matrix of the residuals
            E = patches - dict * coeff_m;

            % SVD to get the closest rank-1 approximation
            [u1, s1, z1] = svds(E(:, non_zero_idx), 1);

            % Subtracts means from new atoms again
            u1 = u1 - mean(u1);

            % Normalize
            u1 = u1 / norm(u1);

            % Update both dictionary and sparse representation
            dict(:, atom_idx) = u1;
            coeff(atom_idx, non_zero_idx) = s1 * z1;
        end

        % Remove ataoms that are potential duplicates and atoms that are
        % not used enough
        dict_new = dict;
        for atom_idx = 2:num_atoms
            dict_copy = dict;
            dict_copy(:, atom_idx) = [];
            if max(dict_copy' * dict(:, atom_idx)) > 0.90 || nnz(coeff(atom_idx, :)) < 10
                new_atom = patches(:, randsample(num_patches, 1));
                new_atom = new_atom / norm(new_atom);
                dict_new(:, atom_idx) = new_atom;
            end
        end
        dict = dict_new;
    end
end