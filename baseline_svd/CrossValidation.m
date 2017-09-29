file_list = dir();

k_ratio_values = [0.55 0.75]; %different parameter values to try
perc_missing_values = [0.2 0.4 0.6 0.8];
avg_errors_per_k_ratio_values = zeros(size(k_ratio_values));

Errors = cell(size(perc_missing_values));
% Stds = cell(size(perc_missing_values));
avg_Errors = zeros(size(perc_missing_values,2),size(k_ratio_values,2)); %different perc. of missing values as rows and paramter values as columns

% Different percentage of missing values
for m = 1:size(perc_missing_values,2)
    k = 1;
    Errors_per_perc_value = [];  % avg (of different rounds) mean squared errors for each image (rows) and parameter value (columns)
%     Std_per_perc_value = []; % std (of different rounds) mean squared errors for each image (rows) and parameter value (columns)

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

        Errors_per_perc_value = [Errors_per_perc_value; zeros(size(k_ratio_values))];
%         Std_per_perc_value = [Std_per_perc_value; zeros(size(k_ratio_values))];

        % Different values of the parameter
        for p = 1:size(k_ratio_values,2)
            n_fold = 7;
            rounds_errors = zeros(1,n_fold);
            % Different rounds of the n_fold cross-validation
            for j = 1:n_fold
                disp(['file name: ',file_name,' % of miss_val: ', num2str(perc_missing_values(m)), ' parameter value: ', num2str(k_ratio_values(p)),' round: ',num2str(j)])
                % Training set (non-missing values) 80% of the image, validation
                % set (missing-values) 20% of the image
                mask = random_mask(512,perc_missing_values(m));
                I_mask = I;
                I_mask(~mask) = 0;

                % Call the main inPainting function
                I_rec = inPainting(I_mask, mask, k_ratio_values(p));

                rounds_errors(j) = mean(mean(mean( ((I - I_rec) ).^2)));
            end % end-rounds

            Errors_per_perc_value(k,p) = mean(rounds_errors);
            Std_per_perc_value(k,p) = std(rounds_errors);

        end % end-different parameter values

        k = k+1;
    end %end-different images

    Errors{m} = Errors_per_perc_value;
%     Stds{m} = Std_per_perc_value;
    avg_Errors(m,:) = mean(Errors_per_perc_value);
end %end-different perc. missing values

save('Errors.mat','Errors');
% save('Stds.mat','Stds');
save('avg_Errors.mat','avg_Errors');
