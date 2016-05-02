
clear; %close all; clc;
compare = true;
hmodel = false;
data_root = 'C:/Developer/data/';
data_sequence = 'teaser_with_video/';
date_path = [data_root, data_sequence];
half_window_size = 20;
start_offset = 20;
end_offset = 80;

line_width = 1;

%% Data Hmodel
if compare || hmodel
    fileID = fopen([date_path, 'hmodel_tracking_error.txt'], 'r');
    hmodel_error = fscanf(fileID, '%f');
    N = length(hmodel_error)/2;
    hmodel_error = reshape(hmodel_error, 2, N)';
    hmodel_error = hmodel_error(start_offset:N - end_offset, :);
    
    hmodel_error(:, 1) = sliding_window_averaging(hmodel_error(:, 1), half_window_size);
    hmodel_error(:, 2) = sliding_window_averaging(hmodel_error(:, 2), half_window_size);
    hmodel_error(:, 2) = 1 - hmodel_error(:, 2);    
    
    hmodel_error = hmodel_error(half_window_size + 1:end - half_window_size - 1, :);
end

%% Data Htrack
if compare || ~hmodel
    fileID = fopen([date_path, 'htrack_tracking_error.txt'], 'r');
    htrack_error = fscanf(fileID, '%f');
    N = length(htrack_error)/2;
    htrack_error = reshape(htrack_error, 2, N)';
    htrack_error = htrack_error(start_offset:N - end_offset, :);
    
    htrack_error(:, 1) = sliding_window_averaging(htrack_error(:, 1), half_window_size);
    htrack_error(:, 2) = sliding_window_averaging(htrack_error(:, 2), half_window_size);
    htrack_error(:, 2) = 1 - htrack_error(:, 2);
    
    htrack_error = htrack_error(half_window_size + 1:end - half_window_size - 1, :);
end

%% Plot results
if compare
    
    %% Metric 1
    figure; hold on;
    plot(1:length(htrack_error), htrack_error(:, 1), 'lineWidth', line_width);
    plot(1:length(hmodel_error), hmodel_error(:, 1), 'lineWidth', line_width);
    
    max_distance = max([htrack_error(:, 1); hmodel_error(:, 1)]);
    %ylim([0, min(max_distance, 15)]);
    legend({'htrack', 'hmodel'});
    title('data-model distance');
    xlabel('frame number');
    ylabel('metric');
    
    %% Metric 2
    figure; hold on;
    plot(1:length(htrack_error), htrack_error(:, 2), 'lineWidth', line_width);
    plot(1:length(hmodel_error), hmodel_error(:, 2), 'lineWidth', line_width);
    
    %ylim([0, 1]);
    legend({'htrack', 'hmodel'});
    title('1 - normalized silhouettes overlap');
    xlabel('frame number');
    ylabel('metric');
end

if ~compare
    if hmodel
        error = hmodel_error;
    else
        error = htrack_error;
    end
    figure; hold on;
    plot(1:length(error), error(:, 1), 'lineWidth', 2);
    max_distance = max(error(:, 1));
    ylim([0, min(max_distance, 15)]);
    title('data-model distance');
    
    figure; hold on;
    plot(1:length(error), error(:, 2), 'lineWidth', 2);
    ylim([0, 1]);
    title('1 - normalized silhouettes overlap');
end

