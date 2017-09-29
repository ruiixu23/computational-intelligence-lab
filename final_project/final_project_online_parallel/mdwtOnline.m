% This function implements the multi-scale dictionary learning algorithm
% using wavelets proposed by B. Ophir, et al [2011].
%
% Input:
%   img: image used to learn the dictionary
%   W: wavelet type to use
%   S: number of decomposition levels (scales)
%   K: number of atoms per dictionary
%   n: size of the dictionary's atoms = neib x neib
% Output:
%   D_hat_b: the learned dictionaries
function D_hat_b = mdwtOnline(img, W, S, K, n)
    % Initialization
    % Set the dictionary matrices for all bands, D_hat_b in n * K for
    % b = 1, 2, ..., 3S+1
    b = 3 * S + 1;

    % Wavelet Decomposition
    % Decompose each of the training-set image using the chosen 2D-Wavelet
    % transforms, each into 3S+1 bands
    decomposed_img = cell(1, b);
    [LL, HL, LH, HH] = dwt2(img, W, 'mode', 'per');
    decomposed_img{1} = HL;
    decomposed_img{2} = LH;
    decomposed_img{3} = HH;

    for scale_level = 1:S-1
        [LL, HL, LH, HH] = dwt2(LL, W, 'mode', 'per');
        decomposed_img{img_idx * 3 + 1} = HL;
        decomposed_img{img_idx * 3 + 2} = LH;
        decomposed_img{img_idx * 3 + 3} = HH;
    end

    decomposed_img{end} = LL;

    % For each band
    %   Extract Patches: Extract patches of size sqrt(n)*sqrt(n) from the
    %   same band of all training set decompositions
    patches = cell(1, b);
    patch_size = sqrt(n);
    parfor band_idx = 1:b
        patches{band_idx} = halfHorizontalOverlappingPatches(decomposed_img{band_idx}, patch_size);
    end

    % For each band
    %   K-SVD: Apply K-SVD separately for each decomposition band to
    %   train the sub-dictionary D_hat_b. This process should be repeated
    %   3S+1 tiems, once per band.
    D_hat_b = cell(1, b);
    parfor band_idx = 1:b
        D_hat_b{band_idx}= ksvd(patches{band_idx}, K);
    end
end