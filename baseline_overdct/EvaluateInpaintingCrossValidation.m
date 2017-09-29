% Measure approximation error and compression ratio for several images.
file_list = dir();
%different parameter values to try
neib = 16;
%  L = [300 441 700 1100];
L = 300;
perc_missing_values = [0.15 0.3];
sigma = [0.01 0.05];
max_iterations = [6 8 10];

Errors_per_missing_values = cell(size(perc_missing_values));
Times_per_missing_values = cell(size(perc_missing_values));


% Different percentage of missing values
for m = 1:size(perc_missing_values,2)
    sigma_L_maxIter = zeros(size(sigma,2),size(L,2),size(max_iterations,2));
    Times_sigma_L_maxIter = zeros(size(sigma,2),size(L,2),size(max_iterations,2));

    % For every value of max_iterations
    for mi = 1:size(max_iterations,2)
        % For every value of sigma
        for s = 1:size(sigma,2)
            errors_images_L = [];
            times_images_L = [];

            k = 1;

            % For every image
            for i = 3:length(dir) % running through the folder
                file_name = file_list(i).name; % get current filename

                % Only keep the images in the loop
                if (length(file_name) < 5)
                    continue;
                elseif ( max(file_name(end-4:end) ~= '2.gif') && max(file_name(end-4:end) ~= '2.png'))
                    continue;
                end

                % Read image, convert to double precision and map to [0,1] interval
                I = imread(file_name);
                I = double(I) / 255;

                errors_images_L = [errors_images_L; zeros(size(L))];
                times_images_L = [errors_images_L; zeros(size(L))];

                % Different values of L
                for p = 1:size(L,2)
                    n_fold = 5;
                    rounds_errors = zeros(1,n_fold);
                    rounds_times = zeros(1,n_fold);
                    disp(['miss% ',num2str(perc_missing_values(m)),' max_it ',num2str(max_iterations(mi)),' sig ',num2str(sigma(s)),' L ',num2str(L(p)),' im ',num2str(k)])

                    % Different rounds of the n_fold cross-validation
                    for j = 1:n_fold
                        % Training set (non-missing values) 80% of the image, validation
                        % set (missing-values) 20% of the image
                        mask = random_mask(512,perc_missing_values(m));
                        I_mask = I;
                        I_mask(~mask) = 0;

                        % Call the main inPainting function
                        tic;
                        I_rec = inPaintingCrossValidation(I_mask, mask, sigma(s), L(p), max_iterations(mi));
                        rounds_times(j) = toc;
                        rounds_errors(j) = mean(mean(mean( ((I - I_rec) ).^2)));

                    end % end-rounds

                    errors_images_L(k,p) = mean(rounds_errors);
                    times_images_L(k,p) = mean(rounds_times);

                end % end-different parameter values

                k = k+1;
            end %end-different images

            sigma_L_maxIter(s,:,mi) = mean(errors_images_L);
            Times_sigma_L_maxIter(s,:,mi) = mean(times_images_L);
        end %end- different sigma values
    end %end-different max iterations values

    Errors_per_missing_values{m} = sigma_L_maxIter;
    Times_per_missing_values{m} = Times_sigma_L_maxIter;
 end %end-different perc. missing values

 save('Errors.mat','Errors_per_missing_values');
 save('Times.mat','Times_per_missing_values');