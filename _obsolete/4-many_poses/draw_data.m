function [] = draw_data(num_points, points)

for i = 1:num_points-1
    line([points{i}(1), points{i + 1}(1)], [points{i}(2), points{i + 1}(2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
end
line([points{1}(1), points{end}(1)], [points{1}(2), points{end}(2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
