% This functions learns a dictionary using K-SVD from several images by
% concatenating them as input

file_list = dir();
k = 1;
neib = 16;
n_atoms = 512;

X = [];

for i = 3:length(dir) % running through the folder

    file_name = file_list(i).name; % get current filename

    % Only keep the images in the loop
    if (length(file_name) < 5)
        continue;
    elseif ( max(file_name(end-4:end) ~= '2.png'))
        continue;
    end

    % Read image, convert to double precision and map to [0,1] interval
    I = imread(file_name);
    I = double(I) / 255;

    X = [X im2col(I, [neib neib], 'distinct')];

    disp(['file name: ',file_name]);

    k = k+1;
end

disp('performs KSVD');
U = ksvd(X,n_atoms);
%save the dictionary to the mat file
save('dictionary.mat', 'U');
