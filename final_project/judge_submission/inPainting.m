% Perform the actual inpainting of the image
%
% Input
%   I: (n x n) masked image
%   mask: (n x n) the mask hidding image information
%
% Output
%   I_rec = Reconstructed image
function I_rec = inPainting(I, mask)
    sigma = 0.05;
    mask(mask ~= 0) = 1;

    % Load dictionary
    dictionaries = load('dictionary.mat');
    U = dictionaries.dictionaries;
    W = 'haar';
    S = 1;
    neib = 8;

    image_filled = fillMissingPixels8Frame(I, mask, 20);

    % Wavelet Decomposition
    b = 3 * S + 1;
    reconstructed_bands = cell(1, b);

    [LL, HL, LH, HH] = dwt2(image_filled, W, 'mode', 'per');
    reconstructed_bands{1} = mergeHalfHorizontalOverlappingPatches(U{1} * sparseCoding(U{1}, halfHorizontalOverlappingPatches(HL, neib), sigma), neib, 256);
    reconstructed_bands{2} = mergeHalfHorizontalOverlappingPatches(U{2} * sparseCoding(U{2}, halfHorizontalOverlappingPatches(LH, neib), sigma), neib, 256);
    reconstructed_bands{3} = mergeHalfHorizontalOverlappingPatches(U{3} * sparseCoding(U{3}, halfHorizontalOverlappingPatches(HH, neib), sigma), neib, 256);

    for scale_level = 1:S-1
        [LL, HL, LH, HH] = dwt2(LL, W, 'mode', 'per');
        image_size = 256 / (2 * scale_level);
        reconstructed_bands{scale_level * 3 + 1} = mergeHalfHorizontalOverlappingPatches(U{scale_level * 3 + 1} * sparseCoding(U{scale_level * 3 + 1}, halfHorizontalOverlappingPatches(HL, neib), sigma), neib, image_size);
        reconstructed_bands{scale_level * 3 + 2} = mergeHalfHorizontalOverlappingPatches(U{scale_level * 3 + 2} * sparseCoding(U{scale_level * 3 + 2}, halfHorizontalOverlappingPatches(LH, neib), sigma), neib, image_size);
        reconstructed_bands{scale_level * 3 + 3} = mergeHalfHorizontalOverlappingPatches(U{scale_level * 3 + 3} * sparseCoding(U{scale_level * 3 + 3}, halfHorizontalOverlappingPatches(HH, neib), sigma), neib, image_size);
    end

    image_size = 256 / S;
    reconstructed_bands{end} = mergeHalfHorizontalOverlappingPatches(U{end} * sparseCoding(U{end}, halfHorizontalOverlappingPatches(LL, neib), sigma), neib, image_size);

    % Wavelet Composition
    LL = reconstructed_bands{(S - 1) * 3 + 4};
    for scale_level = S-1:-1:0
        LL = idwt2(LL, reconstructed_bands{scale_level * 3 + 1}, reconstructed_bands{scale_level * 3 + 2}, reconstructed_bands{scale_level * 3 + 3}, W, 'mode', 'per');
    end

    I_rec = I;
    I_rec(~mask) = LL(~mask);
end