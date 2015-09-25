function [] =  display_tangent(pose, radii)

num_points = pose.num_points;
num_centers = pose.num_centers; 
points = pose.points;
centers = pose.centers;
projections = pose.projections;

figure; hold on; axis equal;

%% Draw data
draw_data(pose.num_points, pose.points);

%% Draw model
draw_model(num_centers, centers, radii);

%% Draw correspondences
for i = 1:num_points
    scatter(points{i}(1), points{i}(2), 30, [1, 0.5, 0.2], 'filled');
    line([projections{i}(1) points{i}(1)], [projections{i}(2) points{i}(2)], 'lineWidth', 2, 'color', [1, 0.8, 0]);
    scatter(projections{i}(1), projections{i}(2), 30, [1, 0.5, 0.2], 'filled');
end


