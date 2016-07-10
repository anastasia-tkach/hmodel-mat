
clear; close all; clc;
compare = true;
hmodel = true;
data_root = 'C:/Developer/data/';
data_sequence = 'MATLAB/energy_terms/';
date_path = [data_root, data_sequence];
half_window_size = 20;
start_offset = 20;
end_offset = 80;

output_path = 'C:\Developer\data\MATLAB\convolution_feel\';

line_width = 3;

figure_size = [0.3, 0.3, 0.3, 0.25];
figure_borders = [0.05 0.08 0.93 0.85];

display_title = false;

%% Data Hmodel
fileID = fopen([date_path, 'hmodel/hmodel_tracking_error.txt'], 'r');
hmodel_error = fscanf(fileID, '%f');
N = length(hmodel_error)/2;
hmodel_error = reshape(hmodel_error, 2, N)';
hmodel_error = hmodel_error(start_offset:N - end_offset, :);

hmodel_error(:, 1) = sliding_window_averaging(hmodel_error(:, 1), half_window_size);
hmodel_error(:, 2) = sliding_window_averaging(hmodel_error(:, 2), half_window_size);
hmodel_error(:, 2) = 2 * hmodel_error(:, 2);

hmodel_error = hmodel_error(half_window_size + 1:end - half_window_size - 1, :);

%% Data Htrack
fileID = fopen([date_path, 'htrack/htrack_tracking_error.txt'], 'r');
htrack_error = fscanf(fileID, '%f');
N = length(htrack_error)/2;
htrack_error = reshape(htrack_error, 2, N)';
htrack_error = htrack_error(start_offset:N - end_offset, :);

htrack_error(:, 1) = sliding_window_averaging(htrack_error(:, 1), half_window_size);
htrack_error(:, 2) = sliding_window_averaging(htrack_error(:, 2), half_window_size);
htrack_error(:, 2) = 2 * htrack_error(:, 2);

htrack_error = htrack_error(half_window_size + 1:end - half_window_size - 1, :);



%% Plot results
full_hmodel_error = hmodel_error;
full_htrack_error = htrack_error;
step = 10;
countE3D = 200;
countE2D = 200;
for f = 2000:step:2719;
    frame = f;
    hmodel_error = full_hmodel_error(1:frame, :);
    htrack_error = full_htrack_error(1:frame, :);
    
    %% Metric 1

    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    plot(1000:length(htrack_error), htrack_error(1000:end, 1), 'lineWidth', line_width, 'color', [93, 139, 171]/255);%[61, 131, 119]/255)
    plot(1000:length(hmodel_error), hmodel_error(1000:end, 1), 'lineWidth', line_width, 'color', [208, 134, 134]/255);%[179, 81, 109]/255
    
    ylim([2, 8]);
    xlim([0, length(full_hmodel_error)]);
    title(num2str(frame));
    if display_title
        title('data-model distance');
        xlabel('frame number');
        ylabel('metric');
    end
    grey_color = [0.3, 0.3, 0.3];
    set(gca,'position', figure_borders, 'units','normalized');
    set(gca,'dataaspectratio', [1359.5, 10.8, 1]);
    set(gca,'fontsize', 16, 'fontname', 'calibri');
    ax = gca;
    ax.LineWidth = 1.7;
    ax.XColor = grey_color;
    ax.YColor = grey_color;
    print([output_path, 'E3D' ,num2str(countE3D)],'-dpng', '-r300'); countE3D = countE3D + 1;

    %% Metric 2
    figure('units', 'normalized', 'outerposition', figure_size); hold on;
    plot(1000:length(htrack_error), htrack_error(1000:end, 2), 'lineWidth', line_width, 'color', [93, 139, 171]/255);
    plot(1000:length(hmodel_error), hmodel_error(1000:end, 2), 'lineWidth', line_width, 'color', [208, 134, 134]/255);
    
    ylim([0, 5]);
    xlim([0, length(full_hmodel_error)]);
    %legend({'E2D for [Tagliasacchi et al. 2015]', 'E2D for [Proposed Method]'}, 'Location','northeast', 'edgecolor', 'none');
    title(num2str(frame));
    if display_title
        title('1 - normalized silhouettes overlap');
        xlabel('frame number');
        ylabel('metric');
    end
    grey_color = [0.3, 0.3, 0.3];
    set(gca,'position', figure_borders, 'units','normalized');
    set(gca,'dataaspectratio', [1359.5, 9, 1]);
    set(gca,'fontsize', 16, 'fontname', 'calibri');
    ax = gca;
    ax.LineWidth = 1.7;
    ax.XColor = grey_color;
    ax.YColor = grey_color;
    print([output_path, 'E2D', num2str(countE2D)],'-dpng', '-r300'); countE2D = countE2D + 1;
    
    %close all;
end




