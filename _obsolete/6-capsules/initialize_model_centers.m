function [centers, radii] = initialize_model_centers(points, num_centers)

P = zeros(length(points), 3);
for i = 1:length(points)
    P(i, :) = points{i}';
end

%% Initialize
centers = cell(num_centers, 1);
radii = cell(num_centers, 1);

figure;
subplot(1, 2, 1); hold on; axis equal; %xlim([0, 1]); ylim([0, 1]);
scatter(P(:, 1), P(:, 2), 30, [0, 0.7, 0.6], 'filled');
for i = 1:num_centers
    [x, y] = ginput(1);
    centers{i} = [x; y];
    hold on; scatter(centers{i}(1), centers{i}(2), 50, 'm', 'filled');
    [xr, yr] = ginput(1);
    r = norm([x - xr, y - yr]);
    radii{i} = r;
    draw_circle(centers{i}, radii{i}, [1, 0.7, 0]);
end

subplot(1, 2, 2); hold on; axis equal;% xlim([0, 1]); ylim([0, 1]);
scatter(P(:, 3), P(:, 2), 30, [0, 0.7, 0.6], 'filled');
for i = 1:num_centers
    line([0, 1], [centers{i}(2), centers{i}(2)], 'color', [0, 0.5, 0.5], 'lineWidth', 2, 'lineStyle', '-.');
    [z, w] = ginput(1);
    centers{i} = [centers{i}; z];
    hold on; scatter(z, w, 50, 'm', 'filled');
    draw_circle([centers{i}(3), centers{i}(2)], radii{i}, [1, 0.7, 0]);
end

%% Display results 
figure; hold on; axis equal;
scatter3(P(:, 1), P(:, 2), P(:, 3), 30, [0, 0.7, 0.6], 'filled');
for i = 1:num_centers
    scatter3(centers{i}(1), centers{i}(2), centers{i}(3), 50, 'm', 'filled');    
end



