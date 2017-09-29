% Perform sparse coding using a modified Orthogonal Matching Pursuit (OMP) tailored to the
% inpainting problem with residual stopping criterion.
%
% Input
%   U: (d x l) unit norm atoms
%   X: (d x n) observations
%   M: (d x n) mask denoting which observations are unknown
%   sigma: residual error stopping criterion, normalized by signal norm
%
% Output
%   Z: MP coding
function Z = sparseCoding(U, X, M, sigma)
    l = size(U,2);
    [patch_size,n] = size(X);
    Z = zeros(l,n);
    % max_iterations = patch_size/2;
    max_iterations = 5;
    E2 = sigma^2*patch_size;

    % Loop over all observations (patches) in the columns of X
    for nn = 1:n
        % Initialize the residual with the observation x
        % For the modification with masking make sure that you only take into
        % account the known observations defined by the mask M
        % Initialize z to zero
        non_missing_values_indeces = M(:, nn)==1;
        non_missing_values = X(non_missing_values_indeces, nn);
        E2M=E2*length(non_missing_values)/patch_size;
        % Select only rows of the dictionary that correspond to non-missing
        % values in X(:,i)
        U_significant = U(non_missing_values_indeces, :);
        % Normalize atoms
        atoms_norm = sqrt(sum(U_significant.^2));
        U_significant = U_significant ./ repmat(atoms_norm, size(U_significant, 1), 1);
        % Initialize residual and rc_max
        residual = non_missing_values;
        previous_atoms = [];
        previous_atoms_indeces = [];
        iterations = 1;
        currResNorm2 = sum(residual.^2);

        % Stopping condition taken from "Sparse and Redundant Representations:
        % From Theory to Applications in Signal and Image Processing (Springer,
        % 2010) - Matlab Package" by Michael Elad
        while currResNorm2>E2M && iterations < max_iterations
            % Select atom with maximum absolute correlation to the residual
            [~, max_index] = max(abs(U_significant'*residual));
            % Add selected atom to the active set
            previous_atoms_indeces = [previous_atoms_indeces max_index];
            previous_atoms = [previous_atoms U_significant(:, max_index)];
            % Solve a least squares problem to obtain a new sparse representation
            % Faster than using pinv(previous_atoms)
            z = (eye(iterations)/(previous_atoms'*previous_atoms))*previous_atoms'*non_missing_values;
            % Update residual
            residual = (non_missing_values - previous_atoms*z);
            iterations = iterations+1;
            currResNorm2=sum(residual.^2);
        end
        if(size(previous_atoms_indeces,2) > 0)
            Z(previous_atoms_indeces,nn) = z;
        end
        % Element of Z(:,nn) has to be divided by the norm of the corresponding
        % atom, since the reconstruction will use the complete U dictionary
        Z(:,nn) = Z(:,nn) ./ atoms_norm';
    end
end