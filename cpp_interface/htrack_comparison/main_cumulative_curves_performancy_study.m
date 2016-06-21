clear; close all; clc;
compare = true;
half_window_size = 5;
start_offset = 150;
end_offset = 80;
line_width = 1;
figure_size = [0.3, 0.3, 0.3, 0.35];
figure_borders = [0.05 0.08 0.93 0.84];

display_title = true;
display_silhouette = false;

data_path = 'E:/Data/MATLAB/performance_study/';

%experiment_names = {'5_iter_no_silhouette', '6_iter_no_silhouette', '7_iter_no_silhouette', '8_iter_no_silhouette', '9_iter_no_silhouette', ...
%    '10_iter_no_silhouette', '15_iter_no_silhouette', '20_iter_no_silhouette', '50_iter_no_silhouette'};
%{'5_iter_with_silhouette', '6_iter_with_silhouette', '7_iter_with_silhouette', '8_iter_with_silhouette', '9_iter_with_silhouette', '10_iter_with_silhouette', '15_iter_with_silhouette', '20_iter_with_silhouette'};

%experiment_names = {'10_iter_no_silhouette', '15_iter_no_silhouette', '20_iter_no_silhouette', '10_iter_with_silhouette', '15_iter_with_silhouette', '20_iter_with_silhouette'};
%experiment_names = {'20_iter_no_silhouette', '20_iter_with_silhouette'};

%% Rigid reweight
experiment_names = {'6_iter', '6_iter_diag', '6_iter_increase_delta', 'hmodel_tracking_error', '7_iter_no_silhouette',  '50_iter_no_silhouette'};

legend_names = cell(length(experiment_names), 1);
for i = 1:length(experiment_names)
    legend_names{i} = strrep(experiment_names{i}, '_', ' ');
end

%% Data Hmodel
errors1 = cell(length(experiment_names), 1);
errors2 = cell(length(experiment_names), 1);
for i = 1:length(experiment_names)
    fileID = fopen([data_path, experiment_names{i}, '.txt'], 'r');
    error = fscanf(fileID, '%f');
    N = length(error)/2;
    error = reshape(error, 2, N)';
    error = error(start_offset:N - end_offset, :);
    
    errors1{i} = error(:, 1);
    
    errors2{i} = error(:, 2);
    
    if mean(errors2{i}) < 0.1
        errors2{i} = errors2{i} * 1000;
    end
    
    errors1{i} = sliding_window_averaging(errors1{i}, half_window_size);
    errors2{i} = sliding_window_averaging(errors2{i}, half_window_size);
    
    errors1{i} = errors1{i}(half_window_size + 1:end - half_window_size - 1, :);
    errors2{i} = errors2{i}(half_window_size + 1:end - half_window_size - 1, :);
end

%% Plot data metric
figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiment_names)
    plot(1:length(errors1{i}), errors1{i}(:, 1), 'lineWidth', 1);
end
legend(legend_names);
if display_title, title('average data-model distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');

%% Plot silhouette metric
if (display_silhouette)
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    for i = 1:length(experiment_names)
        plot(1:length(errors2{i}), errors2{i}(:, 1), 'lineWidth', 1);
    end
    legend(legend_names);
    if display_title, title('average silhouettes distance'); end
    xlabel('frame number');
    ylabel('metric');
    set(gca,'position', figure_borders, 'units','normalized');
end


%% Statistics

num_bins = 100;
if display_silhouette, T = 2; else T = 1; end
for t = 1:T
    %% Data error
    if t == 1
        min_error = 3.3;
        max_error = 5.1;
        errors = errors1;
    end
    
    %% Silhoette error
    if t == 2
        min_error = 1;
        max_error = 3;
        errors = errors2;
    end
    
    thresholds = linspace(min_error, max_error, num_bins);
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    
    for i = 1:length(experiment_names)
        statistics = zeros(length(num_bins), 1);
        for j = 1:length(thresholds)
            statistics(j) = numel(find(errors{i} < thresholds(j))) / numel(errors{i});
        end
        plot(thresholds, statistics, 'lineWidth', line_width);
    end
    xlim([min_error, max_error]);
    legend(legend_names, 'Location','southeast');
    if display_title
        xlabel('error threshold');
        ylabel('% frames with error < threshold');
        if t == 1, title('average data-model distance'); end
        if t == 2, title('average silhouettes distance'); end
    end
    set(gca,'position', figure_borders, 'units','normalized');
end

