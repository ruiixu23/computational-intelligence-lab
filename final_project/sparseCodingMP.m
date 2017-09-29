% Perform sparse coding using a modified version of matching pursuit (MP)
% tailored to the inpainting problem with residual stopping criterion.
%
% Input
%   dict: d by l unit norm atoms
%   img: d by n observations
%   sigma: residual error stopping criterion, normalized by signal norm
%   rc_min: minimal residual correlation before stopping
%
% Output
%   coeff: sparse coding coefficients
function coeff = sparseCodingMP(dict, img, sigma, rc_min)
    max_iters = 4;

    dict_transpose = dict';
    num_atoms = size(dict, 2);
    num_patches = size(img, 2);

    coeff = zeros(num_atoms, num_patches);

    for patch_index = 1:num_patches
        % Initialize residual and rc_max
        patch = img(:, patch_index);
        residual = patch;
        rc_max = Inf;
        iter = 1;

        patch_norm = norm(patch);
        while norm(residual) > sigma * patch_norm && ...
                rc_max > rc_min && iter < max_iters
            % Select atom with maximum absolute correlation to the residual
            [rc_max, max_value_index] = max(abs(dict_transpose * residual));

            % Update the maximum absolute correlation
            atom = dict(:, max_value_index);
            max_abs_correlation = atom' * residual;

            % Update coefficient vector and residual
            coeff(max_value_index, patch_index) = coeff(max_value_index, patch_index) + max_abs_correlation;
            residual = (residual - max_abs_correlation * atom);
            iter = iter + 1;
        end
    end
end