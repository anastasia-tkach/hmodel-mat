

clear; close all; clc;
compare = false;
hmodel = false;
data_root = 'C:/Developer/data/';
data_sequence = 'experiments/';
date_path = [data_root, data_sequence];

if compare || hmodel
    fileID = fopen([date_path, 'hmodel_tracking_error.txt'], 'r');
    hmodel_error = fscanf(fileID, '%f');
    N = length(hmodel_error)/2;
    hmodel_error = reshape(hmodel_error, 2, N)';
end

if compare || ~hmodel
    fileID = fopen([date_path, 'htrack_tracking_error.txt'], 'r');
    htrack_error = fscanf(fileID, '%f');
    N = length(htrack_error)/2;
    htrack_error = reshape(htrack_error, 2, N)';
end

if compare
    figure; hold on;
    plot(1:length(htrack_error), htrack_error(:, 1), 'lineWidth', 2);
    plot(1:length(hmodel_error), hmodel_error(:, 1), 'lineWidth', 2);
    max_distance = max([htrack_error(:, 1); hmodel_error(:, 1)]);
    ylim([0, min(max_distance, 15)]);
    legend({'htrack', 'hmodel'});
    title('data-model distance');
    
    figure; hold on;
    plot(1:length(htrack_error), 1 - htrack_error(:, 2), 'lineWidth', 2);
    plot(1:length(hmodel_error), 1 - hmodel_error(:, 2), 'lineWidth', 2);
    ylim([0, 1]);
    legend({'htrack', 'hmodel'});
    title('1 - silhouettes overlap distance');
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
    plot(1:length(error), 1 - error(:, 2), 'lineWidth', 2);
    ylim([0, 1]);
    title('1 - silhouettes overlap distance');
end