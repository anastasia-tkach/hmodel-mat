
clear; close all; clc;

data_path = 'E:/Data/hmodel-matlab-data/figure_16_compare_sequences/';
half_window_size = 0;
start_offset = 1;
end_offset = 0;

line_width = 1;

figure_size = [0.3, 0.3, 0.4, 0.4];
%figure_borders = [0.05 0.08 0.93 0.90];
figure_borders = [0.05 0.08 0.93 0.82];
display_title = true;
plot_time_sequences = true;

%{
2-concerto1 - rigid motion, clenching fist
4-shidhar1 - extending one finger
4-shidhar2 - fingers contact
4-shidhar4 - crossing fingers
4-shidhar5 - pinching
6-sharp1 - fast articulated motion, unlikely poses, extending finger
6-sharp2 - fast rigid
6-sharp3 - rotating fist
%}

sequences_names = {'concerto1', 'sridhar1', 'sridhar2', 'sridhar4', 'sridhar5', 'sharp1', 'sharp2', 'sharp3'};

start_offsets = [
    150,...%'teaser',
    70, ...%'2-concerto1',
    50, ...%'2-concerto2',
    30, ...%'4-shidhar1',
    1, ...%'4-shidhar2',
    50, ...%'4-shidhar3',
    50, ...%'4-shidhar4',
    40, ...%'4-shidhar5',
    30, ...%'5-qian1',
    50, ...%'6-sharp1',
    50, ...%'6-sharp2',
    50, ...%'6-sharp3'
    ];
end_offsets = [
    80,...%'teaser',
    1, ...%'2-concerto1',
    200, ...%'2-concerto2',
    200, ...%'4-shidhar1',
    50, ...%'4-shidhar2',
    1, ...%'4-shidhar3',
    70, ...%'4-shidhar4',
    1, ...%'4-shidhar5',
    1, ...%'5-qian1',
    50, ...%'6-sharp1',
    1, ...%'6-sharp2',
    1, ...%'6-sharp3'
    ];

indices = [2, 4, 5, 7, 8, 10, 11, 12];
titles = {'tayl1', 'srid1', 'srid2', 'srid3', 'srid4', 'shar1', 'shar2', 'shar3'};
start_offsets = start_offsets(indices);
end_offsets = end_offsets(indices);
teaser_index = 0;

half_window_sizes = [1, 1, 1, 0, 0, 1, 2, 2];

%% Data Hmodel
hmodel_average_errors1 = zeros(length(sequences_names), 1);
hmodel_average_errors2 = zeros(length(sequences_names), 1);
htrack_average_errors1 = zeros(length(sequences_names), 1);
htrack_average_errors2 = zeros(length(sequences_names), 1);


for i = 1:length(sequences_names)
    half_window_size = half_window_sizes(i);
    
    fileID = fopen([data_path, 'new_hmodel/',  sequences_names{i}, '.txt'], 'r');
    hmodel_error = fscanf(fileID, '%f');
    N = length(hmodel_error)/2;
    hmodel_error = reshape(hmodel_error, 2, N)';
    hmodel_error = hmodel_error(start_offsets(i):N - end_offsets(i), :);
    
    hmodel_error(:, 1) = sliding_window_averaging(hmodel_error(:, 1), half_window_size);
    hmodel_error(:, 2) = sliding_window_averaging(hmodel_error(:, 2), half_window_size);    
    
    hmodel_error = hmodel_error(half_window_size + 1:end - half_window_size - 1, :);
    hmodel_average_errors1(i) = mean(hmodel_error(:, 1));
    hmodel_average_errors2(i) = mean(hmodel_error(:, 2));
    
    %% Data Htrack
    fileID = fopen([data_path, 'new_htrack/',  sequences_names{i}, '.txt'], 'r');
    htrack_error = fscanf(fileID, '%f');
    N = length(htrack_error)/2;
    htrack_error = reshape(htrack_error, 2, N)';
    htrack_error = htrack_error(start_offsets(i):N - end_offsets(i), :);
    
    htrack_error(:, 1) = sliding_window_averaging(htrack_error(:, 1), half_window_size);
    htrack_error(:, 2) = sliding_window_averaging(htrack_error(:, 2), half_window_size);
    
    htrack_error = htrack_error(half_window_size + 1:end - half_window_size - 1, :);
    htrack_average_errors1(i) = mean(htrack_error(:, 1));
    htrack_average_errors2(i) = mean(htrack_error(:, 2));
    
    %% Metric 1
    if plot_time_sequences
        figure('units', 'normalized', 'outerposition', figure_size); hold on;
        plot(1:length(htrack_error), htrack_error(:, 1), 'lineWidth', line_width, 'color', [61, 131, 119]/255);
        plot(1:length(hmodel_error), hmodel_error(:, 1), 'lineWidth', line_width, 'color', [179, 81, 109]/255);
        
        max_distance = max([htrack_error(:, 1); hmodel_error(:, 1)]);
        %ylim([0, min(max_distance, 15)]);
        xlim([0, length(hmodel_error)]);
        legend({'[Tagliasacchi et al. 2015]', '[Proposed Method]'}, 'Location','northeast');
        if display_title
            title(['E3D for ', titles{i}]);
            xlabel('frame number');
            ylabel('E3D');
        end
        set(gca,'position', figure_borders, 'units','normalized');
        
        %% Metric 2
        figure('units', 'normalized', 'outerposition', figure_size); hold on;
        plot(1:length(htrack_error), htrack_error(:, 2), 'lineWidth', line_width, 'color', [61, 131, 119]/255);
        plot(1:length(hmodel_error), hmodel_error(:, 2), 'lineWidth', line_width, 'color', [179, 81, 109]/255);
        
        %ylim([0, 1]);
        xlim([0, length(hmodel_error)]);
        legend({'[Tagliasacchi et al. 2015]', '[Proposed Method]'}, 'Location','northeast');
        if display_title
             title(['E2D for ', titles{i}]);
            xlabel('frame number');
            ylabel('E2D');
        end
        set(gca,'position', figure_borders, 'units','normalized');
    end
end

figure('units', 'normalized', 'outerposition', figure_size); hold on;
y = [ htrack_average_errors2, hmodel_average_errors2, htrack_average_errors1, hmodel_average_errors1];
bar_handle = bar(y,'grouped', 'EdgeColor', 'none');

set(bar_handle(1),'FaceColor', [144, 194, 171]/255);
set(bar_handle(2),'FaceColor', [217, 154, 143]/255);
set(bar_handle(3),'FaceColor', [61, 131, 119]/255);
set(bar_handle(4),'FaceColor', [179, 81, 109]/255);

legend({'E2D for [Tagliasacchi et al. 2015]', 'E2D for [Proposed Method]', 'E3D for [Tagliasacchi et al. 2015]', 'E3D for [Proposed Method]'});
%{
seq1: concerto1 - rigid motion, clenching fist, 
seq2: sridhar1 - extending one finger,
seq3: sridhar2 - fingers contact, 
seq4: sridhar4 - crossing fingers,
seq5: sridhar5 - pinching, 
seq6: sharp1 - fast articulated motion, unlikely poses, extending finger,
seq7: sharp2 - fast rigid, 
seq8: sharp3 - rotating fist
%}
text(0.75, -0.3,'tayl1', 'fontsize', 9);
text(1.75, -0.3,'srid1', 'fontsize', 9);
text(2.75, -0.3,'srid2', 'fontsize', 9);
text(3.75, -0.3,'srid3', 'fontsize', 9);
text(4.75, -0.3,'srid4', 'fontsize', 9);
text(5.75, -0.3,'shar1', 'fontsize', 9);
text(6.75, -0.3,'shar2', 'fontsize', 9);
text(7.75, -0.3,'shar3', 'fontsize', 9);

set(gca,'XTick',[]);
set(gca, 'fontsize', 12);


