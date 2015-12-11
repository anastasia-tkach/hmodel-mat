%% Initialize
%clc;
clear;
close all;
set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
%data_path = [absolute_path, '_data\robert_wang\'];
data_path = [absolute_path, '_data\fingers\'];
%data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 3;
test_pose = 0;
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;

total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, num2str(p), '_points']);
    load([data_path, num2str(p), '_centers']);
%     load([data_path, 'points']);
%     load([data_path, 'centers']);
    if (test_pose)
        load([data_path, num2str(test_pose), '_points']);
        load([data_path, num2str(tes5t_pose), '_centers']);
    end
    poses{p}.num_points = length(points);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.num_centers = num_centers;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    if (test_pose)
        display_result_convtriangles(poses{1}, blocks, radii, 2);
        num_poses = 1; break;
    end
end


%% Optimize
settings.sparse_data = false;
settings.closing_radius = 20;
settings.fov = 15;
downscaling_factor = 4;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.energy1 = true; settings.energy2 = true; settings.energy3x = true; settings.energy3y = true; settings.energy3z = true;
num_iters = 3;
history = cell(num_iters + 1, 1);
poses = compute_closing_radius(poses, radii, settings);
settings.sparse_data = false;


for iter = 1:num_iters + 1
    disp(['iter ', num2str(iter)]);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        disp(['     pose ', num2str(p)]);
        
        %% Data fitting energy
        disp('          energy 1');
        [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
        poses{p} = compute_energy1(poses{p}, radii, blocks, D);
        
        %% Silhouette energy
        disp('          energy 3');
        poses{p} = compute_energy3_3D_all_axis(poses{p}, blocks, radii, settings);
        
        %% Save history
        history{iter}.poses{p} = poses{p}; history{iter}.radii = radii; history{iter}.blocks = blocks;
        
    end
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, num_centers, num_parameters, D, '1', settings.energy1);
    
    [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links);
    
    [f3x, J3x] = assemble_energy(poses, num_centers, num_parameters, D, '3x', settings.energy3x);
    [f3y, J3y] = assemble_energy(poses, num_centers, num_parameters, D, '3y', settings.energy3y);
    [f3z, J3z] = assemble_energy(poses, num_centers, num_parameters, D, '3z', settings.energy3z);
    
    %% Compute update
    w1 = 1; w2 = 1; w3 = 1; w4 = 1;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    
    delta = - (w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3x' * J3x + J3y' * J3y + J3z' * J3z) + w4 * I) \ ...
        (w1 * J1' * f1 + w2 * J2' * f2 + w3 * (J3x' * f3x + J3y' * f3y + J3z' * f3z));
    
    %% Add a check is there is a tangent plane for each capsule
    [poses, radii] = apply_update(poses, blocks, radii, delta, D);
    
end
close all;

save([absolute_path, 'rendering\history'], 'history');
examine_history(settings);

