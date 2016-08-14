clear; close all; clc;
compare = true;
hmodel = true;
half_window_size = 0;
start_offset = 152;
end_offset = 80;
line_width = 1;
figure_size = [0.3, 0.3, 0.4, 0.4];
figure_borders = [0.05 0.08 0.93 0.90];

display_title = false;

data_path = 'E:/Data/MATLAB/figure_17_frame_rates/';
experiments_names = {'all', 'r-60fps',  'r-30fps', 'r-15fps', 'r-7.5fps'};

%data_path = 'E:/Data/MATLAB/figure_18_tests/';
%experiments_names = {'tagliasacchi', 'sharp', 'taylor', 'tkach'};


%% Data Hmodel
errors1 = cell(length(experiments_names), 1);
errors2 = cell(length(experiments_names), 1);

speedups = cell(length(experiments_names), 1);
for i = 1:length(experiments_names)
    
    %% Find speed up
    speedups{i} = 1;
    if ~isempty(findstr('30', experiments_names{i})), speedups{i} = 2; end
    if ~isempty(findstr('15', experiments_names{i})), speedups{i} = 4; end
    if ~isempty(findstr('7.5', experiments_names{i})), speedups{i} = 8; end
    
    %% Get the data
    fileID = fopen([data_path, experiments_names{i}, '.txt'], 'r');
    error = fscanf(fileID, '%f');
    N = length(error)/2;
    error = reshape(error, 2, N)';
    error = error(start_offset/speedups{i}:N - end_offset/speedups{i}, :);
    
    errors1{i} = error(:, 1);    
    errors2{i} = error(:, 2);

    %if i <= 1, errors2{i} = 2 * errors2{i}; end
    
    %% Smoothing
    current_half_window_size = ceil(half_window_size/speedups{i});
    
    smooth_errors1{i} = sliding_window_averaging(errors1{i}, current_half_window_size);
    smooth_errors2{i} = sliding_window_averaging(errors2{i}, current_half_window_size);
    
    smooth_errors1{i} = smooth_errors1{i}(current_half_window_size + 1:end - current_half_window_size - 1, :);
    smooth_errors2{i} = smooth_errors2{i}(current_half_window_size + 1:end - current_half_window_size - 1, :);
    
end

%% Plot data metric
figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiments_names)
    plot(speedups{i} * (1:length(smooth_errors1{i})), smooth_errors1{i}(:, 1), 'lineWidth', 1);
end
legend(experiments_names);
if display_title, title('average data-model distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');
set(gca, 'fontsize', 12);
%ylim([0, 12]);

%% Plot silhouette metric
figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiments_names)
    plot(speedups{i} * (1:length(smooth_errors2{i})), smooth_errors2{i}(:, 1), 'lineWidth', 1);
end
legend(experiments_names);
if display_title, title('average silhouettes distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');
ylim([0, 5]);

%% Statistics

num_bins = 100;
for t = 1:2
    %% Data error
    if t == 1
        min_error = 3.3;
        max_error = 10;
        errors = errors1;
    end
    
    %% Silhoette error
    if t == 2
        min_error = 2 * 0.3;
        max_error = 2 * 1.3;
        errors = errors2;
    end
    
    thresholds = linspace(min_error, max_error, num_bins);
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    
    for i = 1:length(experiments_names)
        statistics = zeros(length(num_bins), 1);
        for j = 1:length(thresholds)
            statistics(j) = numel(find(errors{i} < thresholds(j))) / numel(errors{i});
        end
        plot(thresholds, statistics, 'lineWidth', line_width);
    end
    %xlim([min_error, max_error]);
    legend(experiments_names, 'Location','southeast');
    if display_title
        xlabel('error threshold');
        ylabel('% frames with error < threshold');
        if t == 1, title('average data-model distance'); end
        if t == 2, title('average silhouettes distance'); end
    end
    set(gca,'position', figure_borders, 'units','normalized');
    set(gca, 'fontsize', 12);
end

