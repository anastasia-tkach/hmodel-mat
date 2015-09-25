clear; clc; close all;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_parameters = D * num_centers * num_poses + num_centers;

p = 1;
% load([data_path, num2str(p), '_points']);
% load([data_path, num2str(p), '_centers']);
load([data_path, 'points']);
load([data_path, 'centers']);
poses{p}.num_points = length(points);
poses{p}.points = points;
poses{p}.centers = centers;
poses{p}.num_centers = num_centers;

total_num_points = 0; cumsum_num_points = zeros(num_poses + 1, 1);
total_num_points = total_num_points + poses{p}.num_points;
cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;

H = 480/4; W = 640/4;
RAND_MAX = 32767;
view_axis = 'Z';
[rendered_model, camera_axis, camera_center, fov] = render_model(centers, blocks, radii, W, H, view_axis);
rendered_model_to_display = rendered_model(:, :, 3);
rendered_model_to_display(rendered_model_to_display == -RAND_MAX) = -10;
figure; imshow(rendered_model_to_display, []);

%% Get 2.5D model
[I, J] = find(rendered_model(:, :, 3) > - RAND_MAX);
display_result_convtriangles(poses{p}, blocks, radii, false); hold on;
samples = cell(length(I), 1);
for k = 1:length(I)
    samples{k} = squeeze(rendered_model(I(k), J(k), :));    
end


%% Compute correspondences
[indices, projections, ~] = compute_projections(samples, poses{p}.centers, blocks, radii);

% S = zeros(length(samples), 3);
% Q = zeros(length(projections), 3);
% for i = 1:length(samples)
%     S(i, :) = samples{i}';
%     if ~isempty(projections{i}) 
%         Q(i, :) = projections{i}';
%     end
% end
% scatter3(S(:, 1), S(:, 2), S(:, 3), 10, 'filled', 'o', 'b'); 
% scatter3(Q(:, 1), Q(:, 2), Q(:, 3), 10, 'filled', 'o', 'm'); 

%% Render data points
focal = H/tand(fov/2);

a = camera_axis; 
t = camera_center;
A = [focal, 0,      W/2;
    0,     focal,   H/2;
    0,     0,       1];

figure; imshow(zeros(H, W, 3)); hold on;
set(gcf, 'Position',[100 100 W H]); 
axis image; axis off;
set(gca, 'Units', 'pixels', 'Position', [1 1 W H]);

index = randi([1, length(samples)], 1, 1);
for i = [index]
    M = [points{i}; 1];    
    if strcmp(view_axis, 'Z')
        b = [0; 0; -1];
        R = vrrotvec2mat(vrrotvec(a, b));
        P = A * [R -R*t];
        m = P * M;
        m = m ./ m(3);
        m = [W - m(1); m(2)];
    end
    if strcmp(view_axis, 'Y')
        b = [0; -1; 0];
        R = vrrotvec2mat(vrrotvec(a, b));
        R = [R(1, :); R(3, :); R(2, :)];
        P = A * [R -R*t];
        m = P * M;
        m = m ./ m(3);
        m = [m(1); m(2)];
    end
    if strcmp(view_axis, 'X')
        b = [-1; 0; 0];
        R = vrrotvec2mat(vrrotvec(a, b));
        R = [R(2, :); R(3, :); R(1, :)];
        P = A * [R -R*t];          
        m = P * M;
        m = m ./ m(3);
        m = [W - m(1); m(2)];
    end
    scatter(m(1), m(2), 1, 'filled', 'w');
    mypoint(m, 'm');
    disp(m);
end


% axis equal; axis off; xlim([1 W]); ylim([1 H]);
% data_silhouette = frame2im(getframe);
% figure; imshow(data_silhouette);
% data_silhouette = double(data_silhouette(:, :, 1) ./ 255);
% [distance_transform] = dtform(data_silhouette);
% figure, imagesc(distance_transform), axis equal; axis off;

return
%% Optimize
num_iters = 4;
for iter = 1:num_iters
    disp(iter);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    %% Energy1
    [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    
    display_result_convtriangles(poses{p}, blocks, radii, 2);
    
    poses{p} = compute_energy1(poses{p}, radii, D);
    
    f1 = zeros(total_num_points, 1);
    J1 = zeros(total_num_points, num_parameters);
    for p = 1:num_poses
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc;
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
        f1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
    end
    
    %% Model-data energy
    
    %% Compute updates
    alpha = 1;
    gamma = 0;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    delta = - (alpha * (J1' * J1) + gamma * I) \ (alpha * J1' * f1);
    
    %% Add a check is there is a tangent plane for each capsule
    [poses, radii] = apply_update(poses, blocks, radii, delta, D);
    
end

return;

%% Render model silhouette

n = 50; factor = 2;
[xy_distances, yz_distances, distances] = silhouette_convtriangles(poses{p}, blocks, radii, n);

[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[X_xy, Y_xy] = meshgrid(xm, ym);
[Z_zy, Y_zy] = meshgrid(zm, ym);
figure; contourf(X_xy, Y_xy, xy_distances, 200, 'edgeColor', 'none');
colormap([0 0 0; 1, 1, 1]); caxis([-1 1]);
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]); axis off;
position = get(gcf, 'position');
set(gcf, 'position', [position(1), position(2), position(3)/factor, position(4)/factor]);
model_silhouette = frame2im(getframe); close;
model_silhouette = double((255 - model_silhouette(:, :, 1)) ./ 255);
figure; imshow(model_silhouette); axis equal; axis off;
[U, V] = find(model_silhouette);
scale_ratio_x = n / size(model_silhouette, 2);
scale_ratio_y = n / size(model_silhouette, 1);

