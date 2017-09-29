% Perform sparse coding using a modified version of Orthogonal Matching
% Pursuit (OMP) tailored to the inpainting problem with residual stopping
% criterion.
%
% Input
%   dict: d by l unit norm atoms
%   img: d by n observations
%   sigma: residual error stopping criterion, normalized by signal norm
%   rc_min: minimal residual correlation before stopping
%
% Output
%   coeff: sparse coding coefficients
function coeff = sparseCodingOMP(dict, img, sigma, rc_min)
    [patch_size, num_patches] = size(img);
    [atom_size, num_atoms] = size(dict);
    max_iters = 6;
    E2 = sigma ^ 2 * patch_size;
    dict_transpose = dict';
    coeff = zeros(num_atoms, num_patches);

    for patch_index = 1:num_patches
        % Initialize the residual with the observation since mask is not
        % used here
        patch = img(:, patch_index);
        residual = patch;

        selected_atoms = zeros(atom_size, max_iters);
        selected_atoms_transpose = zeros(max_iters, atom_size);
        selected_atoms_indices = zeros(1, max_iters);

        iter = 1;
        residual_norm_square = sum(residual .^ 2);

        % Stopping condition taken from "Sparse and Redundant Representations:
        % From Theory to Applications in Signal and Image Processing (Springer,
        % 2010) - Matlab Package" by Michael Elad
        while residual_norm_square > E2 && iter < max_iters
            % Select atom with maximum absolute correlation to the residual
            [~, max_value_index] = max(abs(dict_transpose * residual));

            % Add selected atom to the active set
            selected_atoms_indices(iter) = max_value_index;
            atom = dict(:, max_value_index);
            selected_atoms(:, iter) = atom;
            selected_atoms_transpose(iter, :) = atom';

            % Solve the least squares problem to obtain a new sparse representation
            atoms = selected_atoms(:, 1:iter);
            atoms_transpose = selected_atoms_transpose(1:iter, :);
            z = (eye(iter) / (atoms_transpose * atoms)) * atoms_transpose(1:iter, :) * patch;

            % Update residual
            residual = (patch - atoms * z);
            residual_norm_square = sum(residual .^ 2);

            % Increment iteration
            iter = iter + 1;
        end

        if iter > 1
            coeff(selected_atoms_indices(1, 1:iter - 1), patch_index) = z;
        end
    end
end