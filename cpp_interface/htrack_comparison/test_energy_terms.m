
clear; close all; clc;
compare = true;
hmodel = false;
date_path = 'C:/Developer/data/MATLAB/energy_terms/';
half_window_size = 20;
start_offset = 20;
end_offset = 80;
line_width = 2;

experiments_names = {'no_silhouette', 'no_pca', 'no_jointlimits', 'no_collisions', 'no_temporal', 'all'};

%% Data Hmodel
errors1 = cell(length(experiments_names), 1);
errors2 = cell(length(experiments_names), 1);
for i = 1:length(experiments_names)
    fileID = fopen([date_path, experiments_names{i}, '.txt'], 'r');
    error = fscanf(fileID, '%f');
    N = length(error)/2;
    error = reshape(error, 2, N)';
    error = error(start_offset:N - end_offset, :);
    
    errors1{i} = error(:, 1);
    errors2{i} = 1 - error(:, 2);
    errors1{i} = sliding_window_averaging(errors1{i}, half_window_size);
    errors2{i} = sliding_window_averaging(errors2{i}, half_window_size);
    
    errors1{i} = errors1{i}(half_window_size + 1:end - half_window_size - 1, :);
    errors2{i} = errors2{i}(half_window_size + 1:end - half_window_size - 1, :);
end

%% Plot data metric
figure; hold on;
for i = 1:length(experiments_names)
    plot(1:length(errors1{i}), errors1{i}(:, 1), 'lineWidth', 1);
end
legend({'no silhouette', 'no pca', 'no jointlimits', 'no collisions', 'no temporal', 'all'});
title('average data-model distance');
xlabel('frame number');
ylabel('metric');

%% Plot silhouette metric
figure; hold on;
for i = 1:length(experiments_names)
    plot(1:length(errors2{i}), errors2{i}(:, 1), 'lineWidth', 1);
end
legend({'no silhouette', 'no pca', 'no jointlimits', 'no collisions', 'no temporal', 'all'});
title('1 - normalized silhouettes overlap');
xlabel('frame number');
ylabel('metric');



%% Statistics

num_bins = 100;
for t = 1:2    
    %% Data error
    if t == 1
        min_error = 3.2;
        max_error = 5.5;
        errors = errors1;
    end
    
    %% Silhoette error
    if t == 2        
        min_error = 0.07;
        max_error = 0.4;
        errors = errors2;
    end
        
    thresholds = linspace(min_error, max_error, num_bins);
    figure; hold on;
    for i = 1:length(experiments_names)
        statistics = zeros(length(num_bins), 1);
        for j = 1:length(thresholds)
            statistics(j) = numel(find(errors{i} < thresholds(j))) / numel(errors{i});
        end
        plot(thresholds, statistics, 'lineWidth', line_width);
    end
    xlim([min_error, max_error]);
    legend({'no silhouette', 'no pca', 'no jointlimits', 'no collisions', 'no temporal', 'all'});
    xlabel('error threshold');
    ylabel('% frames with error < threshold');
    if t == 1, title('average data-model distance'); end
    if t == 2, title('1 - normalized silhouettes overlap'); end
end

