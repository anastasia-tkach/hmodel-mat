settings_default;
settings_ik;


%% Load input
load([data_path, 'radii.mat']); load([data_path, 'blocks.mat']);
num_poses = 1; 
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;
poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, num2str(p), '_points.mat']); poses{p}.points = points;
    load([data_path, num2str(p), '_centers.mat']); poses{p}.centers = centers;
    %load([data_path, num2str(p), '_normals.mat']); poses{p}.normals = normals;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    %P = zeros(length(poses{p}.points), settings.D);
    %for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
    %poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
end
poses = compute_closing_radius(poses, radii, settings);
history = cell(num_iters + 1, 1);

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
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, true);
        poses{p} = compute_energy3(poses{p}, blocks, radii, settings, true);
        %poses{p} = compute_energy3_3D_all_axis(poses{p}, blocks, radii, settings, true);
        
    end
   
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, num_centers, num_parameters, D, '1', settings.energy1);
    [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links);
    [f3x, J3x] = assemble_energy(poses, num_centers, num_parameters, D, '3x', settings.energy3x);
    [f3y, J3y] = assemble_energy(poses, num_centers, num_parameters, D, '3y', settings.energy3y);
    [f3z, J3z] = assemble_energy(poses, num_centers, num_parameters, D, '3z', settings.energy3z);
    [f4, J4] = assemble_energy(poses, num_centers, num_parameters, D, '4', settings.energy4);
    
    %% Save history
    success_iter = success_iter + 1;
    history{success_iter}.f1 = f1; history{success_iter}.f2 = f2; history{success_iter}.f3x = f3x; history{success_iter}.f3y = f3y; history{success_iter}.f3z = f3z; history{success_iter}.f4 = f4;
    history{success_iter}.J1 = J1; history{success_iter}.J2 = J2; history{success_iter}.J3x = J3x; history{success_iter}.J3y = J3y; history{success_iter}.J3z = J3z; history{success_iter}.J4 = J4;
    history{success_iter}.energy = w1 * (f1' * f1) + w2 * (f2' * f2) + w3 * (f3x' * f3x + f3y' * f3y + f3z' * f3z) + w5 * (f4' * f4);
    if history{success_iter}.energy == 0, break; end
    history{success_iter}.poses = poses; history{success_iter}.radii = radii; history{success_iter}.blocks = blocks;
    
    %% Compare residuals and roll back if required
    if iter > 1 && settings.linear_search
        if history{success_iter}.energy < history{success_iter - 1}.energy || w4 > 100
            w4 = w4 / 2;
            disp(['    damping = ', num2str(w4)]);
        else
            w4 = w4 * 10;
            radii = history{success_iter - 1}.radii; blocks = history{success_iter - 1}.blocks; poses = history{success_iter - 1}.poses;
            f1 = history{success_iter - 1}.f1; f2 = history{success_iter - 1}.f2; f3x = history{success_iter - 1}.f3x; ...
                f3y = history{success_iter - 1}.f3y; f3z = history{success_iter - 1}.f3z; f4 = history{success_iter - 1}.f4;
            J1 = history{success_iter - 1}.J1; J2 = history{success_iter - 1}.J2; J3x = history{success_iter - 1}.J3x; ...
                J3y = history{success_iter - 1}.J3y; J3z = history{success_iter - 1}.J3z; J4 = history{success_iter - 1}.J4;
            success_iter = success_iter - 1;
            disp('    ONE ITERATION IS REJECTED');
            disp(['    damping = ', num2str(w4)]);
            close(findobj('type','figure','name', ['energy 1, iter ', num2str(settings.iter)]));
            close(findobj('type','figure','name', ['energy 3, iter ', num2str(settings.iter)]));
        end
    end
    
    %% Compute update
    fr  = zeros(num_parameters, 1);
    Jr = zeros(num_parameters, num_parameters);
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Block degrees of freedom for debug
    %J3x(:, blocked_dof) = zeros(size(J3x, 1), length(blocked_dof));
    
    %% Apply update
    settings.w4 = w4;
    while true
        delta = - (w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3x' * J3x + J3y' * J3y + J3z' * J3z) + w4 * I + wr * (Jr' * Jr) + w5 * (J4' * J4)) \ ...
            (w1 * J1' * f1 + w2 * J2' * f2 + w3 * (J3x' * f3x + J3y' * f3y + J3z' * f3z + wr * Jr' * fr + w5 * J4' * f4));
        
        [valid_update, new_poses, new_radii] = apply_update(poses, blocks, radii, delta, D);
        if (valid_update), break; end
        w4 = w4 * 2;
    end
    disp(['    update = ', num2str(delta')]);
    w4 = settings.w4;
    poses = new_poses; radii = new_radii;
    
    
end

save([absolute_path, 'rendering\history'], 'history');
%examine_history(settings, history);
%display_hand_sketch(poses, radii, blocks);

