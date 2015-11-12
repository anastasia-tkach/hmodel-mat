clear;
set_path;
%clc;
close all;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
% data_path = [absolute_path, '_data\robert_wang\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_parameters = D * num_centers * num_poses + num_centers;
num_links = sum(cellfun('length', blocks));

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
axis_to_view = containers.Map();
axis_to_view('X') = [-90, 0];
axis_to_view('Y') = [0, 0];
axis_to_view('Z') = [0, -90];
downscaling_factor = 4;
closing_radius = 32 / downscaling_factor;
H = 480/downscaling_factor; W = 640/downscaling_factor;  view_axis = 'Z'; RAND_MAX = 32767;
settings.energy3x = false;
settings.energy3y = true;
settings.energy3z = false;
num_iters = 2;
for iter = 1:num_iters
    display_result_convtriangles(poses{p}, blocks, radii, true); view(axis_to_view(view_axis));
    
    %disp(iter);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        %display_result_convtriangles(poses{p}, blocks, radii, true); view(axis_to_view(view_axis)); camlight;
        poses{p} = compute_projective_view(poses{p}, blocks, radii, W, H, view_axis, closing_radius);
        
        
        P = zeros(length(poses{p}.model_points), 3);
        for i = 1:length(poses{p}.model_points)
            P(i, :) = poses{p}.model_points{i}';
        end
        scatter3(P(:, 1), P(:, 2), P(:, 3), 10, 'o', 'filled', 'y');
        
        [poses{p}.model_indices, ~, ~] = compute_projections(poses{p}.model_points, poses{p}.centers, blocks, radii);
        [poses{p}, f, Jc, Jr] = compute_energy3_given_axis(poses{p}, radii, blocks, view_axis, H, W, D);
        poses{p}.f3 = f; poses{p}.Jc3 = Jc; poses{p}.Jr3 = Jr;
        
    end
    if (iter == num_iters), break; end
    %% Compose linear system
    f3 = zeros(total_num_points, 1);
    J3 = zeros(total_num_points, num_parameters);
    for p = 1:num_poses
        total_num_points = total_num_points + length(poses{p}.f3);
        cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f3);
    end
    J3(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc3;
    J3(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr3;
    f3(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f3;
    
%     J3_ = zeros(size(J3));
%     index = 13;
%     J3_(:, index) = J3(:, index);
%     J3 = J3_;
    %% Compute update
    disp([ 'ENERGY = ',num2str(sum(f3))]);
    f1 = zeros(total_num_points, 1);
    J1 = zeros(total_num_points, num_parameters);
    f2 = zeros(num_links, 1);
    J2 = zeros(num_links, num_parameters);
    w1 = 0;  w2 = 0; w3 = 1; w4 = 1;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    delta = - (w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3) + w4 * I) \ ...
        (w1 * J1' * f1 + w2 * J2' * f2 + w3 * (J3' * f3));
    
    %% Add a check is there is a tangent plane for each capsule
    [poses, radii] = apply_update(poses, blocks, radii, delta, D);
end



%% Compute projection jacobian
% k = randi([1, length(model_points)], 1, 1);
% [q, m, dm] = compute_projection_jacobian(centers, radii, model_points{k}, indices{k}, P, view_axis, H, W);

%% Display in 3D
% if (display)
%     figure; display_result_convtriangles(poses{p}, blocks, radii, false); hold on;
%     mypoint(model_points{k}, 'm');
%     mypoint(q, 'b');
% end

