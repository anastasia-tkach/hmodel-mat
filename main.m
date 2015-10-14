settings_default;

%% One radius is allowed to change
%settings_test1;

%% Two radii are allowed to change
%settings_test2;

%% Two radii are allowed to change. The model is completely outside the data
%settings_test3;

%% Two radii are allowed to change. The model that initially has small radii. FAILURE CASE
%settings_test4;

%% One center is allowed to move in plane
%settings_test5

%% Two center are allowed to move in plane. FAILURE CASE
%settings_test6

%% One center is allowed to move in plane. Crazy overshooting. FAILURE CASE
%settings_test7

%% One center is allowed to move in plane. Crazy overshooting. FAILURE CASE
%settings_test8


%% Load input
load([data_path, 'radii.mat']); load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'solids.mat']); solids = [blocks; solids];
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;
poses = cell(num_poses, 1);

for k = start_pose:start_pose + num_poses - 1
    p = k - start_pose + 1;
    switch settings.mode
        case 'fitting', load([data_path, num2str(k), '_centers.mat']); poses{p}.centers = centers;
        case 'tracking', load([data_path, 'centers.mat']); poses{p}.centers = centers;
    end
    load([data_path, num2str(k), '_points.mat']); poses{p}.points = points;
    load([data_path, num2str(k), '_normals.mat']); poses{p}.normals = normals;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    if settings.D == 3
        P = zeros(length(poses{p}.points), settings.D);
        for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
        poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
    end
    poses{p} = compute_distance_invariants(poses{p}, solids);
end

poses = compute_closing_radius(poses, radii, settings);
history = cell(num_iters + 1, 1);

%% Reduce data
blocks = blocks(1:4);
solids = {}; solids{1} = [3, 4, 5, 6];
poses{1}.points = poses{1}.points(1000:1000);
poses{1}.normals = poses{1}.normals(1000:1000);
display_result_convtriangles(poses{1}, blocks, radii, false); mypoints(poses{1}.points, 'm'); drawnow;
P = zeros(length(poses{p}.points), settings.D);
for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
poses{p}.kdtree = createns(P, 'NSMethod','kdtree');

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter; disp(['ITER ', num2str(success_iter + 1)]);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    if iter == 5,
        disp(' ');
    end
    
    for p = 1:num_poses
        %disp(['pose ', num2str(p)]);
        
        %% Data fitting energy
        poses{p} = compute_energy1(poses{p}, radii, blocks, settings, true);
        
        %% Silhouette energy
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, true);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
        
    end
    %% Shape consistency energy
    [f2, J2] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links, settings);
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, num_centers, num_parameters, '1', settings);
    [f3x, J3x] = assemble_energy(poses, num_centers, num_parameters, '3x', settings);
    [f3y, J3y] = assemble_energy(poses, num_centers, num_parameters, '3y', settings);
    [f3z, J3z] = assemble_energy(poses, num_centers, num_parameters, '3z', settings);
    [f4, J4] = assemble_energy(poses, num_centers, num_parameters, '4', settings);
    [f5, J5] = assemble_energy(poses, num_centers, num_parameters, '5', settings);
    
    %% Save history
    success_iter = success_iter + 1;
    history{success_iter}.f1 = f1; history{success_iter}.f2 = f2; history{success_iter}.f3x = f3x; history{success_iter}.f3y = f3y; history{success_iter}.f3z = f3z;
    history{success_iter}.f4 = f4; history{success_iter}.f5 = f5;
    history{success_iter}.J1 = J1; history{success_iter}.J2 = J2; history{success_iter}.J3x = J3x; history{success_iter}.J3y = J3y; history{success_iter}.J3z = J3z;
    history{success_iter}.J4 = J4; history{success_iter}.J5 = J5;
    history{success_iter}.energy = w1 * (f1' * f1) + w2 * (f2' * f2) + w3 * (f3x' * f3x + f3y' * f3y + f3z' * f3z) + w4 * (f4' * f4) +  w5 * (f5' * f5);
    if history{success_iter}.energy == 0, break; end
    history{success_iter}.poses = poses; history{success_iter}.radii = radii; history{success_iter}.blocks = blocks;
    
    %% Compare residuals and roll back if required
    if iter > 1 && settings.linear_search
        if history{success_iter}.energy < history{success_iter - 1}.energy || damping > 1000
            damping = damping / 2;
            disp(['    damping = ', num2str(damping)]);
        else
            damping = damping * 10;
            radii = history{success_iter - 1}.radii; blocks = history{success_iter - 1}.blocks; poses = history{success_iter - 1}.poses;
            f1 = history{success_iter - 1}.f1; f2 = history{success_iter - 1}.f2; f3x = history{success_iter - 1}.f3x; f3y = history{success_iter - 1}.f3y; f3z = history{success_iter - 1}.f3z;
            f4 = history{success_iter - 1}.f4; f5 = history{success_iter - 1}.f5;
            J1 = history{success_iter - 1}.J1; J2 = history{success_iter - 1}.J2; J3x = history{success_iter - 1}.J3x; J3y = history{success_iter - 1}.J3y; J3z = history{success_iter - 1}.J3z;
            J4 = history{success_iter - 1}.J4; J5 = history{success_iter - 1}.J5;
            success_iter = success_iter - 1;
            disp('    ONE ITERATION IS REJECTED');
            disp(['    damping = ', num2str(damping)]);
            %close(findobj('type','figure','name', ['energy 1, iter ', num2str(settings.iter)]));
        end
    end
    
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Block degrees of freedom for debug
    %J3x(:, blocked_dof) = zeros(size(J3x, 1), length(blocked_dof));
    
    %% Apply update
    w5 = settings.w5;
    while true
        LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w4 * (J4' * J4) +  w5 * (J5' * J5);
        rhs = w1 * J1' * f1 + w2 * J2' * f2 + w4 * J4' * f4 + w5 * J5' * f5;
        delta = -  LHS \ rhs;
        
        [valid_update, new_poses, new_radii, change_indices] = apply_update(poses, blocks, radii, delta, D);
        if (valid_update), break; end
        w5 = w5 * 2; disp(num2str(w5));
        for p = 1:num_poses, poses{p} = compute_energy5(new_poses{p}, new_radii, blocks, settings); end
        [f5, J5] = assemble_energy(new_poses, num_centers, num_parameters, '5', settings);
    end
    disp(['    update = ', num2str(delta')]);
    poses = new_poses; radii = new_radii;
    
    
end

save([absolute_path, 'rendering\history'], 'history');
%examine_history(settings, history);
%display_hand_sketch(poses, radii, blocks);
%display_result_convtriangles(poses{1}, blocks, radii, false); mypoints(pose.points, 'm'); drawnow;

