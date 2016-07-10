%clear; close all; clc;
compare = true;
half_window_size = 0;
start_offset = 1;
end_offset = 50;
line_width = 1;
figure_size = [0.3, 0.3, 0.3, 0.35];
figure_borders = [0.05 0.08 0.93 0.84];

display_title = true;
display_silhouette = false;

num_iters = 6;

data_path = 'E:/Data/MATLAB/figure_16_compare_sequences/';



%% Rigid reweight
%experiment_names = {'energy_terms/htrack/htrack_tracking_error', 'htrack_tracking_error', 'htrack_rastorized_error'};
experiment_names = {'hmodel/6-sharp3', 'hmodel/p-6-sharp3', 'hmodel/r-6-sharp3', ...
    'htrack/6-sharp3', 'htrack/p-6-sharp3', 'htrack/r-6-sharp3'};

legend_names = cell(length(experiment_names), 1);
for i = 1:length(experiment_names)
    legend_names{i} = strrep(experiment_names, '_', ' ');
end

figure('units', 'normalized', 'outerposition', figure_size); hold on;
for i = 1:length(experiment_names)
       
    fileID = fopen([data_path, experiment_names{i}, '.txt'], 'r');
    hmodel_error = fscanf(fileID, '%f');
    
    hmodel_error = reshape(hmodel_error, 2, length(hmodel_error)/2)';        

    N = length(hmodel_error);
    
    hmodel_error = hmodel_error(start_offset:N - end_offset, :);
    

        
    hmodel_error(:, 1) = sliding_window_averaging(hmodel_error(:, 1), half_window_size);
    hmodel_error(:, 2) = sliding_window_averaging(hmodel_error(:, 2), half_window_size);
    hmodel_error(:, 2) = 2 * hmodel_error(:, 2);    
   
    hmodel_error = hmodel_error(half_window_size + 1:end - half_window_size - 1, :);
    
    %% Metric 1
    %%{
    plot(1:length(hmodel_error), hmodel_error(1:end, 1), 'lineWidth', line_width);

    legend(experiment_names);
    if display_title       
        xlabel('frame number');
        ylabel('E3D');
    end
    set(gca,'position', figure_borders, 'units','normalized');
    %%}
    
    %% Metric 2  
    %{
    plot(1:length(hmodel_error), hmodel_error(:, 2), 'lineWidth', line_width);
    
    legend(experiment_names);
    if display_title
        title('1 - normalized silhouettes overlap');
        xlabel('frame number');
        ylabel('metric');
    end
    set(gca,'position', figure_borders, 'units','normalized');
    %}
    
end

