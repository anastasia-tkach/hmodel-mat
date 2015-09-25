%% Initialize
%clc;
clear;
close all;
set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
%data_path = [absolute_path, '_data\robert_wang\'];
%data_path = [absolute_path, '_data\fingers\'];
data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
test_pose = 0;
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;

poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, num2str(p), '_points']);
    load([data_path, num2str(p), '_centers']);
    if (test_pose)
        load([data_path, num2str(test_pose), '_points']);
        load([data_path, num2str(tes5t_pose), '_centers']);
    end
    poses{p}.num_points = length(points);
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.num_centers = num_centers;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    if (test_pose)
        display_result_convtriangles(poses{1}, blocks, radii, 2);
        num_poses = 1; break;
    end
end


%% Settings
settings.sparse_data = false;
settings.closing_radius = 20;
settings.fov = 15;
downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D;
settings.energy1 = true; settings.energy2 = true; settings.energy3x = true; settings.energy3y = true; settings.energy3z = true;
num_iters = 4;
history = cell(num_iters + 1, 1);
poses = compute_closing_radius(poses, radii, settings);
settings.sparse_data = false;

%% Compute weights
w1 = 1; w4 = 30;
total_num_points = 0;
total_num_pixels = 0;
for p = 1:num_poses
    total_num_points = total_num_points + poses{p}.num_points;
    total_num_pixels = total_num_pixels + poses{p}.num_pixels;
end
w2 = total_num_points / num_centers / D;
w3 = 10 * total_num_points / total_num_pixels;
settings.w1 = w1; settings.w2 = w2; settings.w3 = w3; settings.w4 = w4;
settings.factor = 1.5;

%% Optimize
success_iter =  0;
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
        
    end
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, num_centers, num_parameters, D, '1', settings.energy1);
    [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links);
    [f3x, J3x] = assemble_energy(poses, num_centers, num_parameters, D, '3x', settings.energy3x);
    [f3y, J3y] = assemble_energy(poses, num_centers, num_parameters, D, '3y', settings.energy3y);
    [f3z, J3z] = assemble_energy(poses, num_centers, num_parameters, D, '3z', settings.energy3z);
    
    %% Save history
    success_iter = success_iter + 1;
    history{success_iter}.f1 = f1; history{success_iter}.f2 = f2; history{success_iter}.f3x = f3x; history{success_iter}.f3y = f3y; history{success_iter}.f3z = f3z;
    history{success_iter}.J1 = J1; history{success_iter}.J2 = J2; history{success_iter}.J3x = J3x; history{success_iter}.J3y = J3y; history{success_iter}.J3z = J3z;
    history{success_iter}.energy = w1 * (f1' * f1) + w2 * (f2' * f2) + w3 * (f3x' * f3x + f3y' * f3y + f3z' * f3z);
    history{success_iter}.poses = poses; history{success_iter}.radii = radii; history{success_iter}.blocks = blocks;
    
    %% Compare residuals and roll back if required
    if iter > 1
        if history{success_iter}.energy < history{success_iter - 1}.energy || w4 > 100
            w4 = w4 / 2;
        else
            radii = history{success_iter - 1}.radii; blocks = history{success_iter - 1}.blocks; poses = history{success_iter - 1}.poses;
            f1 = history{success_iter - 1}.f1; f2 = history{success_iter - 1}.f2; f3x = history{success_iter - 1}.f3x; f3y = history{success_iter - 1}.f3y; f3z = history{success_iter - 1}.f3z;
            J1 = history{success_iter - 1}.J1; J2 = history{success_iter - 1}.J2; J3x = history{success_iter - 1}.J3x; J3y = history{success_iter - 1}.J3y; J3z = history{success_iter - 1}.J3z;
            w4 = w4 * 2;
            success_iter = success_iter - 1;
        end
    end
    disp(w4);
    
    %% Compute update
    
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    
    while true    
        delta = - (w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3x' * J3x + J3y' * J3y + J3z' * J3z) + w4 * I) \ ...
        (w1 * J1' * f1 + w2 * J2' * f2 + w3 * (J3x' * f3x + J3y' * f3y + J3z' * f3z));
        [valid_update, new_poses, new_radii] = apply_update(poses, blocks, radii, delta, D);
        if (valid_update), break; end 
        w4 = w4 * 2;
    end
    poses = new_poses; radii = new_radii;

    
end
close all;

save([absolute_path, 'rendering\history'], 'history');
examine_history(settings, history);

