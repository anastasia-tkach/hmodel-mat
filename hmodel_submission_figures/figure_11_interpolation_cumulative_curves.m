
clear; close all; clc;
compare = true;
hmodel = true;
half_window_size = 0;
start_offset = 150;
end_offset = 80;
line_width = 1;
figure_size = [0.3, 0.3, 0.4, 0.4];
figure_borders = [0.05 0.08 0.93 0.90];

display_title = false;

data_path = 'E:/Data/MATLAB/figure_11_htrack_hmodel_interpolation/';

%experiments_names = {'hmodel', 'interpolation2', 'interpolation3', 'interpolation4', 'interpolation5', 'htrack'};
%experiments_names = {'p-hmodel', 'p-interpolation2', 'p-interpolation3', 'p-interpolation4', 'p-interpolation5', 'p-htrack'};
experiments_names = {'hmodel', 'interpolation2', 'interpolation3', 'interpolation4', 'interpolation5', 'htrack'};

%% Data Hmodel
errors1 = cell(length(experiments_names), 1);
errors2 = cell(length(experiments_names), 1);
for i = 1:length(experiments_names)
    fileID = fopen([data_path, experiments_names{i}, '.txt'], 'r');
    error = fscanf(fileID, '%f');
    N = length(error)/2;
    error = reshape(error, 2, N)';
    error = error(start_offset:N - end_offset, :);
    
    errors1{i} = error(:, 1);
    
    errors2{i} = error(:, 2);


    errors1{i} = sliding_window_averaging(errors1{i}, half_window_size);
    errors2{i} = sliding_window_averaging(errors2{i}, half_window_size);
    
    errors1{i} = errors1{i}(half_window_size + 1:end - half_window_size - 1, :);
    errors2{i} = errors2{i}(half_window_size + 1:end - half_window_size - 1, :);
end

%% Plot data metric
figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiments_names)
    plot(1:length(errors1{i}), errors1{i}(:, 1), 'lineWidth', 1);
end
legend(experiments_names);
if display_title, title('average data-model distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');
set(gca, 'fontsize', 12);

%% Plot silhouette metric
figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiments_names)
    plot(1:length(errors2{i}), errors2{i}(:, 1), 'lineWidth', 1);
end
legend(experiments_names);
if display_title, title('average silhouettes distance'); end
xlabel('frame number');
ylabel('metric');
set(gca,'position', figure_borders, 'units','normalized');
set(gca, 'fontsize', 12);

%% Statistics

num_bins = 100; 
for t = 1:2
    %% Data error
    if t == 1
       min_error = 3;
       max_error = 7;        
       errors = errors1;
    end
    
    %% Silhoette error
    if t == 2
        min_error = 0.5;
        max_error = 4;
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
    xlim([min_error, max_error]);
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

