%clear; close all; clc;
compare = true;
half_window_size = 20;
start_offset = 120;
end_offset = 60;
line_width = 1;
figure_size = [0.3, 0.3, 0.3, 0.35];
figure_borders = [0.05 0.08 0.93 0.84];

display_title = true;
display_silhouette = false;

num_iters = 6;

data_path = 'E:/Data/MATLAB/performance_study/';

%% Rigid reweight
experiment_names = 'levenberg_marquardt_experiments/6_iters';

legend_names = cell(length(experiment_names), 1);
for i = 1:length(experiment_names)
    legend_names{i} = strrep(experiment_names, '_', ' ');
end

%% Data Hmodel
fileID = fopen([data_path, experiment_names, '.txt'], 'r');
error = fscanf(fileID, '%f');
N = length(error)/2;
error = reshape(error, 2, N)';
errors_cropped = error(start_offset * num_iters + 1:N - end_offset * num_iters, :);
errors_by_iter = zeros(length(errors_cropped)/num_iters, num_iters);
for j = 1:length(errors_cropped)/num_iters
    for k = 1:num_iters
        errors_by_iter(j, k) = errors_cropped((j - 1) * num_iters + k);
    end
end
for k = 1:num_iters
    errors_by_iter(:, k) = sliding_window_averaging(errors_by_iter(:, k), half_window_size);    
end
errors_by_iter = errors_by_iter(half_window_size + 1:end - half_window_size - 1, :);


%% Load "Ground truth"
fileID = fopen([data_path, '50_iter_no_silhouette.txt'], 'r');
error = fscanf(fileID, '%f');
N = length(error)/2;
error = reshape(error, 2, N)';
error = error(start_offset + 1:N - end_offset, :);
errors_ground_truth = error(:, 1);
errors_ground_truth = sliding_window_averaging(errors_ground_truth, half_window_size);
errors_ground_truth = errors_ground_truth(half_window_size + 1:end - half_window_size - 1, :);

%% Errors by iter
figure('units', 'normalized', 'outerposition', figure_size); hold on;

plot(1:length(errors_by_iter), errors_by_iter(:, 2:6), 'lineWidth', 1);
plot(1:length(errors_ground_truth), errors_ground_truth, 'lineWidth', 1);

%legend(legend_names);
if display_title, title('average data-model distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');


