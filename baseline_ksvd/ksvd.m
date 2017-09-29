% Perform the K-SVD algorithm for dictionary learning
%
% Input
%   X: (d x n) observations
%   L: Number of dictionary atoms
%
% Output
%   U: Learned dictionary
%
% Config Values:
%   Set L = neib*neib+50 (number of atoms in the dictionary)
%   Set Iterations = 80 as it is stated in the paper http://www.cs.technion.ac.il/~elad/publications/journals/2004/32_KSVD_IEEE_TSP.pdf
function U = ksvd(X, L)
    % fixed iteration - maybe we can optimize the number of iterations later on as well
    % iterations = 80 As it is stated in the paper http://www.cs.technion.ac.il/~elad/publications/journals/2004/32_KSVD_IEEE_TSP.pdf
    iterations = 10;

    % Subtract means already in data matrix X, to find column entirely filled
    % with same value
    X_reduced = X - repmat(mean(X), size(X, 1), 1);

    % Remove columns of X_reduced entirely filled of zeros (1 in zeros_idx)
    X_reduced(:, ~any(X_reduced, 1)) = [];

    % Initialize dictionary by selecting random data patches
    idx = randsample(size(X_reduced, 2), L);
    U = X_reduced(:, idx);

    % Normalize
    U = U ./ repmat(sqrt(sum(U.^2)), size(U, 1), 1);

    % Set first element to be constant, it is the only one with non-zero mean
    U(:, 1) = ones(size(U(:, 1)));
    U(:, 1) = U(:, 1) / norm(U(:, 1));

    % Mask needed in sparseCoding method - M useless here, so we use all the
    % pixels
    M = ones(size(X));

    % Main loop
    for i = 1:iterations
        disp(['Iteration: ', num2str(i)]);

        % Sparse coding with current dictionary
        Z = sparseCoding(U, X, M, 0.05);

        for j = randperm(L)
            % Constant term is not updated
            if j == 1
                continue;
            end
            % Consider only nonzero elements
            Zm = Z;
            Zm(j, :) = 0;
            idx = Z(j, :) ~= 0;
            % Update matrix of the residuals
            E = X - U*Zm;
            E = E(:, idx);

            % SVD to get the closest rank-1 approximation
            [u1, s1, z1] = svds(E,1);

            % Subtracts means from new atoms again
            u1 = u1 - mean(u1);
            % Normalize again
            u1 = u1 / norm(u1);
            % Update both dictionary and sparse representation
            U(:, j) = u1;
            Z(j, idx) = s1*z1;
        end

        % Remove ataoms that are potential duplicates and atoms that are
        % not used enough
        U_new = U;
        for atom_idx = 2:size(U, 2)
            U_copy = U;
            U_copy(:, atom_idx) = [];
            if max(U_copy' * U(:, atom_idx)) > 0.95 || nnz(Z(atom_idx, :)) < 5
                new_atom = X_reduced(:, randsample(size(X_reduced, 2), 1));
                new_atom = new_atom / norm(new_atom);
                U_new(:, atom_idx) = new_atom;
            end
        end
        U = U_new;
    end
end