% This function implements the multi-scale dictionary learning algorithm
% using wavelets proposed by B. Ophir, et al [2011].
%
% Input:
%   filename: name of file to store the learned dictionary and related parameters
%   W: wavelet type to use
%   S: number of decomposition levels (scales)
%   K: number of atoms per dictionary
%   n: size of the dictionary' atoms = neib x neib
function mdwt(filename, W, S, K, n)
    images = load_images();
    dictionaries = build_dictionary(images, W, S, K, n);
    save(filename, 'dictionaries', 'W', 'S', 'K', 'n');
end

% This function loads the training images.
%
% Output:
%   images      The training images
function images = load_images()
    files = dir();
    num_images = 0;
    for i = 3:length(dir)
        filename = files(i).name;

        if (length(filename) < 5)
            continue;
        elseif (max(filename(end-4:end) ~= '2.png'))
            continue;
        end

        num_images = num_images + 1;
    end

    j = 1;
    images = cell(1, num_images);
    for i = 3:length(dir)
        filename = files(i).name;

        if (length(filename) < 5)
            continue;
        elseif (max(filename(end-4:end) ~= '2.png'))
            continue;
        end

        % Load original image
        image = imread(filename);
        image = double(image) / 255;

        disp(['loaded image: ',filename]);

        images{j} = image;

%         figure;
%         imshow(images{j});

        j = j + 1;
    end
end

% This function implements the actual dictionary learning algorithm
% Input:
%   images          Training images
%   W               Wavelet type to use
%   S               Number of decomposition levels (scales)
%   K               Number of atoms per dictionary
%   n               Size of the dictionary' atoms
%
% Output:
%   D_hat_b    The learned dictionaries
function D_hat_b = build_dictionary(images, W, S, K, n)
    % Initialization
    % Set the dictionary matrices for all bands, D_hat_b in n * K for
    % b = 1, 2, ..., 3S+1
    b = 3 * S + 1;

    % Wavelet Decomposition
    % Decompose each of the training-set images using the chosen 2D-Wavelet
    % transforms, each into 3S+1 bands
    decomposed_images = cell(1, size(images, 2));
    for image_index = 1:size(images, 2)
        decomposed_image = cell(1, b);
        [LL, HL, LH, HH] = dwt2(images{image_index}, W, 'mode', 'per');
        decomposed_image{1} = HL;
        decomposed_image{2} = LH;
        decomposed_image{3} = HH;

        for scale_level = 1:S-1
            [LL, HL, LH, HH] = dwt2(LL, W, 'mode', 'per');
            decomposed_image{image_index * 3 + 1} = HL;
            decomposed_image{image_index * 3 + 2} = LH;
            decomposed_image{image_index * 3 + 3} = HH;
        end

        decomposed_image{end} = LL;
        decomposed_images{image_index} = decomposed_image;
    end

    % For each band
    %   Extract Patches: Extract patches of size sqrt(n)*sqrt(n) from the
    %   same band of all training set decompositions
    patches = cell(1, b);
    for band_index = 1:b
        band_patch = [];
        for image_index = 1:size(images, 2)
            band_patch = [band_patch halfHorizontalOverlappingPatches(decomposed_images{image_index}{band_index}, sqrt(n))];
        end

        patches{band_index} = band_patch;
    end

    % For each band
    %   K-SVD: Apply K-SVD separately for each decomposition band to
    %   train the sub-dictionary D_hat_b. This process should be repeated
    %   3S+1 tiems, once per band.
    D_hat_b = cell(1, b);
    for band_index = 1:b
        disp(['ksvd for band ', num2str(band_index)]);
        D_hat_b{band_index}= ksvd(patches{band_index}, K);
    end
end