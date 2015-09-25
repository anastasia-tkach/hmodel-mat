% close all; clear;
% addpath(genpath('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel'));
% load('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\simple_3d\points');
% load('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\simple_3d\radii');
% load('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\simple_3d\centers');

function [] = examine_fitting(pose, radii)
centers = pose.centers;
points = pose.points;
model_correspondences = pose.correspondences;

num_centers = length(centers);

P = zeros(length(points), 3);
for i = 1:length(points)
    P(i, :) = points{i}';
end

model = {};
figure; axis equal; hold on;
for i = 1:num_centers - 1
    mesh = generate_segment_mesh(centers{i}, centers{i + 1}, radii{i}, radii{i + 1});
    draw_projected_mesh(mesh, 'XY');
    model{i} = mesh;
end
scatter(P(:, 1), P(:, 2), 30, [0, 0.7, 0.6], 'filled');

%% Define a plane
u = zeros(2, 2);
for i = 1:2
    [x, y] = ginput(1);
    scatter(x, y, 20, 'm', 'filled');
    u(1, i) = x;
    u(2, i) = y;
end
line(u(1, :), u(2, :), 'color', 'm', 'lineWidth', 3);
u = u(:, 2) - u(:, 1);
u = [u; 0];
u = u / norm(u);
v = [0; 0; 1];
w = cross(u, v);

%% Cut the mesh
k = 1;
for m = 1:length(model)
    mesh = model{m};
    for i = 1:size(mesh.triangles, 1)
        p1 = mesh.vertices(mesh.triangles(i, 1), :);
        p2 = mesh.vertices(mesh.triangles(i, 2), :);
        p3 = mesh.vertices(mesh.triangles(i, 3), :);
        [is_intersect, intersection] = intersect_plane_triangle(w, [x, y, 0], p1, p2, p3);
        if is_intersect
            intersections{k} = intersection;
            k = k + 1;
        end
    end
end

%% Draw the crossection
B = [u, v, w];
figure; axis equal; hold on;
for i = 1:length(intersections)
    p1 = intersections{i}(:, 1);
    alpha = B \ p1;
    p2 = intersections{i}(:, 2);
    beta = B \ p2;
    line([alpha(2), beta(2)], [alpha(1), beta(1)], 'lineWidth', 2, 'color',  [196/255, 153/255, 177/255]);
end

%% Cut the cloud
k = 1;
%figure; hold on;
projections = zeros(length(points), 3);
p0 = [x; y; 0];
distances = zeros(length(points), 1);
for i = 1:length(points)
    p = points{i};
    d = (p - p0)' * w;
    distances(i) = abs(d);
    projections(i, :) = (p - w * d)';
    k = k + 1;
end

[~, indices] = sort(distances);
num_projections = 15;
projections = projections(indices(1:num_projections), :);
model_correspondences = model_correspondences(indices(1:num_projections));

%% Draw projections
for i = 1:length(projections)
    p = projections(i, :)';
    m = model_correspondences{i};
    alpha = B \ p;
    beta = B \ m;
    scatter(alpha(2), alpha(1), 20, 'b', 'filled');
    scatter(beta(2), beta(1), 20, 'm', 'filled');
    direction = (beta - alpha) / norm (beta - alpha);
    distance = norm(p - m);
    line([alpha(2), alpha(2) + direction(2) * distance], [alpha(1), alpha(1) + direction(1) * distance]);
end
axis equal;








