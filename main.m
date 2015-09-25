%% Initialize
%clc;
clear;
close all;
set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\'];
%data_path = [absolute_path, '_data\silhouettes_2D\convsegment\'];
%data_path = [absolute_path, '_data\fingers\'];
data_path = [absolute_path, '_data\convtriangles\negative_radius\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;

poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, num2str(p), '_points']);
    load([data_path, num2str(p), '_centers']);
    poses{p}.num_points = length(points);
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.num_centers = num_centers;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
end


%% Settings
settings.r_min = 0.5;
settings.sparse_data = false;
settings.closing_radius = 25;
settings.fov = 15;
downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D;
settings.energy1 = true; 
settings.energy2 = false; 
settings.energy3x = true; 
settings.energy3y = true; 
settings.energy3z = true;

num_iters = 7;
history = cell(num_iters + 1, 1);
poses = compute_closing_radius(poses, radii, settings);
settings.sparse_data = false;


%% Compute weights
w1 = 1; w2 = 1; w3 = 1; w4 = 1; wr = 1000000;

%% Optimize
success_iter =  0;
for iter = 1:num_iters
    settings.iter = iter; disp(['ITER ', num2str(success_iter + 1)]);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        %disp(['     pose ', num2str(p)]);
        
        %% Data fitting energy
        %disp('          energy 1');
        if D == 2, [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections_matlab(poses{p}.points, poses{p}.centers, blocks, radii); end
        if D == 3, [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii); end
        poses{p} = compute_energy1(poses{p}, radii, blocks, settings, true);
        
        %% Silhouette energy
        %disp('          energy 3');
        %poses{p} = compute_energy3(poses{p}, blocks, radii, settings, true);
        poses{p} = compute_energy3_3D_all_axis(poses{p}, blocks, radii, settings, true);
        
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
            w4 = w4 * 10;
            radii = history{success_iter - 1}.radii; blocks = history{success_iter - 1}.blocks; poses = history{success_iter - 1}.poses;
            f1 = history{success_iter - 1}.f1; f2 = history{success_iter - 1}.f2; f3x = history{success_iter - 1}.f3x; f3y = history{success_iter - 1}.f3y; f3z = history{success_iter - 1}.f3z;
            J1 = history{success_iter - 1}.J1; J2 = history{success_iter - 1}.J2; J3x = history{success_iter - 1}.J3x; J3y = history{success_iter - 1}.J3y; J3z = history{success_iter - 1}.J3z;
            success_iter = success_iter - 1;
            disp('    ONE ITERATION IS REJECTED');    
            close(findobj('type','figure','name', ['energy 1, iter ', num2str(settings.iter)]));
            close(findobj('type','figure','name', ['energy 3, iter ', num2str(settings.iter)]));
        end
    end    
    disp(['    damping = ', num2str(w4)]);
    
    %% Compute update
    fr  = zeros(num_parameters, 1);
    Jr = zeros(num_parameters, num_parameters);
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    w4_before = w4;
    wr = 1000000;
    while true
        delta = - (w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3x' * J3x + J3y' * J3y + J3z' * J3z) + w4 * I + wr * (Jr' * Jr)) \ ...
            (w1 * J1' * f1 + w2 * J2' * f2 + w3 * (J3x' * f3x + J3y' * f3y + J3z' * f3z + wr * Jr' * fr));
        
        %% Add constraints on r_min
        new_radii = zeros(length(radii), 1);
        for o = 1:length(radii)
            new_radii(o) = radii{o} + delta(D * num_centers * num_poses + o);
        end
        if ~isempty(find(new_radii < 0)) && (wr < 1e16)
            wr = wr * 2;
            disp(['    wr = ', num2str(wr)]);
            contraint_indices = find(new_radii < 0);
            for o = contraint_indices
                fr(D * num_centers * num_poses + o) = settings.r_min - radii{o};
                Jr(D * num_centers * num_poses + o, D * num_centers * num_poses + o) = 1;
            end
            if (wr > 1e16), continue; end
        end        
        [valid_update, new_poses, new_radii] = apply_update(poses, blocks, radii, delta, D);
        if (valid_update), break; end
        w4 = w4 * 2;
    end
    disp(['    update = ', num2str(delta')]);
    w4 = w4_before;
    poses = new_poses; radii = new_radii;
    
    
end
%close all;

save([absolute_path, 'rendering\history'], 'history');
%examine_history(settings, history);

