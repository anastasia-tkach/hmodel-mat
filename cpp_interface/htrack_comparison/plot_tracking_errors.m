clear; close all; clc;
path = 'C:/Developer/hmodel-cuda-build/data/sensor/';

fileID = fopen([path, 'hmodel_tracking_error.txt'], 'r');
hmodel_error = fscanf(fileID, '%f');
N = length(hmodel_error)/2;
hmodel_error = reshape(hmodel_error, 2, N)';

fileID = fopen([path, 'htrack_tracking_error.txt'], 'r');
htrack_error = fscanf(fileID, '%f');
N = length(htrack_error)/2;
htrack_error = reshape(htrack_error, 2, N)';

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