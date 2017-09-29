% Perform the actual inpainting of the image using SVD
%
% Input
%   I: the masked image
%   mask: the mask hidding image information
%   model_selection_ration: model selection ration of SVD
%
% Output
%   img_rec = the reconstructed image

function I_rec = inPainting(I, mask)
    model_selection_ratio = 0.6;
    mask(~mask) = 0;

    image_filled = fillMissingPixelsPatchMean(I, mask, 4);

    % We can use the baseline solution as an initialization step to obtain
    % missing values predictions to perform SVD
    % svd(X,0):  economy size decomposition. If X is m-by-n with m > n,
    % then svd computes only the first n columns of U and S is n-by-n.
    [U, D, V] = svd(image_filled,0);

    % MODEL SELECTION: choice of k
    % Keep a percentage of the total variance
    highest_sing_values = find(cumsum(diag(D)) / sum(diag(D)) > model_selection_ratio);
    k = highest_sing_values(1);

    I_approx = U(:,1:k) * D(1:k,1:k) * V(:,1:k)';
    I_rec = I;
    I_rec(mask == 0) = I_approx(mask == 0);
end