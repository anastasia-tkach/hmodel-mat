
clear; %close all; clc;
compare = true;
hmodel = true;
data_root = 'C:/Developer/data/';
data_sequence = 'MATLAB/energy_terms/';
date_path = [data_root, data_sequence];
half_window_size = 20;
start_offset = 20;
end_offset = 80;

line_width = 1;

figure_size = [0.3, 0.3, 0.3, 0.35];
figure_borders = [0.05 0.08 0.93 0.90];

display_title = false;

%% Data Hmodel
if compare || hmodel
    fileID = fopen([date_path, 'hmodel/hmodel_tracking_error.txt'], 'r');
    hmodel_error = fscanf(fileID, '%f');
    N = length(hmodel_error)/2;
    hmodel_error = reshape(hmodel_error, 2, N)';
    hmodel_error = hmodel_error(start_offset:N - end_offset, :);
    
    hmodel_error(:, 1) = sliding_window_averaging(hmodel_error(:, 1), half_window_size);
    hmodel_error(:, 2) = sliding_window_averaging(hmodel_error(:, 2), half_window_size);
    hmodel_error(:, 2) = 2 * hmodel_error(:, 2);    
    
    hmodel_error = hmodel_error(half_window_size + 1:end - half_window_size - 1, :);
end

%% Data Htrack
if compare || ~hmodel
    fileID = fopen([date_path, 'htrack/htrack_tracking_error.txt'], 'r');
    htrack_error = fscanf(fileID, '%f');
    N = length(htrack_error)/2;
    htrack_error = reshape(htrack_error, 2, N)';
    htrack_error = htrack_error(start_offset:N - end_offset, :);
    
    htrack_error(:, 1) = sliding_window_averaging(htrack_error(:, 1), half_window_size);
    htrack_error(:, 2) = sliding_window_averaging(htrack_error(:, 2), half_window_size);
    htrack_error(:, 2) = 2 * htrack_error(:, 2);
    
    htrack_error = htrack_error(half_window_size + 1:end - half_window_size - 1, :);
end

%% Plot results
if compare
    
    %% Metric 1
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    plot(1:length(htrack_error), htrack_error(:, 1), 'lineWidth', line_width, 'color', [61, 131, 119]/255);
    plot(1:length(hmodel_error), hmodel_error(:, 1), 'lineWidth', line_width, 'color', [179, 81, 109]/255);
    
    max_distance = max([htrack_error(:, 1); hmodel_error(:, 1)]);
    %ylim([0, min(max_distance, 15)]);
    xlim([0, length(hmodel_error)]);
    legend({'E3D for [Tagliasacchi et al. 2015]', 'E3D for [Proposed Method]'}, 'Location','northeast', 'edgecolor', 'none');
    if display_title
        title('data-model distance');
        xlabel('frame number');
        ylabel('metric');
    end
    set(gca,'position', figure_borders, 'units','normalized');
    
    %% Metric 2
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    plot(1:length(htrack_error), htrack_error(:, 2), 'lineWidth', line_width, 'color', [61, 131, 119]/255);
    plot(1:length(hmodel_error), hmodel_error(:, 2), 'lineWidth', line_width, 'color', [179, 81, 109]/255);
    
    %ylim([0, 1]);
    xlim([0, length(hmodel_error)]);
    legend({'E2D for [Tagliasacchi et al. 2015]', 'E2D for [Proposed Method]'}, 'Location','northeast', 'edgecolor', 'none');
    if display_title
        title('1 - normalized silhouettes overlap');
        xlabel('frame number');
        ylabel('metric');
    end
    set(gca,'position', figure_borders, 'units','normalized');
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
    
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    plot(1:length(error), error(:, 2), 'lineWidth', 2);
    ylim([0, 1]);
    title('1 - normalized silhouettes overlap');
    set(gca,'position', figure_borders, 'units','normalized');
end


