% Builds a dictionary with atoms of specified dimension
%
% INPUT
% dim: The dimensionality of the dictionary atoms
% X: (d x n) observations - used to learn dictionary if not into file yet
%
% OUTPUT:
% U (d x l) dictionary with unit norm atoms

function U = buildDictionary(X,dim,L)
    try
        temp = load('dictionary.mat');
        disp('dictionary loaded from file');
        U = temp.U;
    catch
        % TO DO: need to set L for the dictionary  - try with dim, dim +1 ...
        % and get the optimal solution with kind of cross-validation like
        % approach
        disp('performs KSVD');
        U = ksvd(X,L);
        %save the dictionary to the mat file
        save('dictionary.mat', 'U');
    end
end
