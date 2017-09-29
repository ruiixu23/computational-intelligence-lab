% Measure approximation error for several images.
%
% NOTE Images must be have .png ending and reside in the ./data/ folder.

k = 1;
% mean squared errors for each image
Errors = [];
vectorizedErrors = [];
for i = 1:64
    % get current filename
    file_name = ['./data/' int2str(i) '_512x512.png'];
    mask_name = './data/mask.png';
    disp(['Restoring image: ' file_name]);
    % Read image, convert to double precision and map to [0,1] interval
    I = imread(file_name);
    I = double(I) / 255;

    % Read the respective binary mask
    mask = imread(mask_name);
%     mask = generateMask(128);

    I_mask = I;
    I_mask(~mask) = 0;

    % Call the main inPainting function
    I_rec = inPainting(I_mask, mask);

    % Measure approximation error
    Errors(k) = mean(mean(mean(((I - I_rec)).^2)));
    k = k+1;
end

disp(['Average quadratic error: ' num2str(mean(Errors))]);
disp(['Std: ' num2str(std(Errors))]);