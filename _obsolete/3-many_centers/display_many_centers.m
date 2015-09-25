function [] = display_many_centers(P, centers, radii)

num_centers = length(centers);

figure; hold on; axis equal;

line(P(:, 1), P(:, 2), 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
for i = 1:num_centers
    scatter(centers{i}(1), centers{i}(2), 30, [0, 0.9, 0.6], 'filled');
    draw_circle(centers{i}, radii{i}, [0, 0.8, 0.7]);
end

for i = 1:num_centers - 1; 
    line([centers{i}(1), centers{i + 1}(1)], [centers{i}(2), centers{i + 1}(2)], 'lineWidth', 2, 'color', [0, 0.8, 0.7]);
    draw_tangents([radii{i}, radii{i + 1}], [centers{i}'; centers{i + 1}'], [0, 0.8, 0.7]);
end