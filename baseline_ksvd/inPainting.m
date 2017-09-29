% Perform the actual inpainting of the image - by using DICTIONARIES
%
% Input
%   I: (n x n) masked image
%   mask: (n x n) the mask hidding image information
%
% Output
%   I_rec: Reconstructed image
function I_rec = inPainting(I, mask)
    neib = 8; % neib: The patch sizes used in the decomposition of the image
    sigma = 0.05; % sigma: residual error stopping criterion, normalized by signal norm

    % Convert mask to 0 and 1 instead of 0 and 255
    % 0 in the original mask is a black pixel, therefore it is a missing value in the image
    % to reconstruct
    mask = mask ~= 0;

    % Get patches of size neib x neib from the image and the mask and
    % convert each patch to 1D signal
    X = im2col(I, [neib neib], 'distinct');
    M = im2col(mask, [neib neib], 'distinct');

    % Construct dictionary
    U = buildDictionary(X,neib*neib,512);

    % Do the sparse coding with modified Matching Pursuit
    Z = sparseCoding(U, X, M, sigma);

    % You need to do the image reconstruction using the known image information
    % and for the missing pixels use the reconstruction from the sparse coding.
    % The mask will help you to distinguish between these two parts.

    rec = col2im(U*Z,[neib neib],size(I),'distinct');
    I_rec = I;
    missing_values_indices = mask == 0;
    I_rec(missing_values_indices) = rec(missing_values_indices);
end
