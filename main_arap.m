settings_default;

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
end

poses = compute_closing_radius(poses, radii, settings);
history = cell(num_iters + 1, 1);
blocks{39} = [35, 44];
blocks{40} = [43, 49];


solid_blocks = {
    [1], [2, 3], [4], ...
    [5], [6, 7], [8], ...
    [9], [10, 11], [12], ...
    [13], [14, 15], [16], ...
    [17], [18, 19], [20], ...
    [21], [22], [23], [24], [25], [26], [27, 28, 29, 30, 32, 33], [31], [34], [35], [36, 37, 38], [39], [40]};

solids = blocks;
solids{41} = [7, 14];
solids{42} = [21, 28];
solids{43} = [14, 21];
poses{1} = compute_distance_invariants(poses{1}, solids);

%% Reduce data
% blocks = blocks(1:4);
% poses{1}.centers = poses{1}.centers(1:7);
% radii = radii(1:7);
% solid_blocks = {[1], [2, 3], [4]};
% num_centers = length(radii);
% display_result_convtriangles(poses{1}, blocks, radii, true); drawnow;
% P = zeros(length(poses{p}.points), settings.D);
% for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
% poses{p}.kdtree = createns(P, 'NSMethod','kdtree');

%% Set up data structures
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        k = k + 1;
    end
end

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter; disp(['ITER ', num2str(success_iter + 1)]);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        %disp(['pose ', num2str(p)]);
        
        %% Data fitting energy
        %poses{p} = compute_energy1(poses{p}, radii, blocks, settings, false);
        
        %% Silhouette energy
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, true);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
        
        %% Tracking energy
        [f1, J1, f2, J2] = compute_energy_arap(poses{p}, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, true);
               
    end
    %% Shape consistency energy
    [f3, J3] = compute_energy2(poses, blocks, num_centers, num_parameters, num_links, settings);
    [f4, J4] = assemble_energy(poses, num_centers, num_parameters, '4', settings);
    [f5, J5] = assemble_energy(poses, num_centers, num_parameters, '5', settings);
    if (iter > num_iters), break; end
    
    %% Save history
    success_iter = success_iter + 1;
    history{success_iter}.f1 = f1; history{success_iter}.f2 = f2; history{success_iter}.f3 = f3; history{success_iter}.f4 = f4; history{success_iter}.f5 = f5; 
    history{success_iter}.J1 = J1; history{success_iter}.J2 = J2; history{success_iter}.J3 = J3; history{success_iter}.J4 = J4; history{success_iter}.J5 = J5;
    history{success_iter}.energy = w1 * (f1' * f1) + w2 * (f2' * f2) +  w3 * (f3' * f3) + w4 * (f4' * f4) + w5 * (f5' * f5);
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
            f1 = history{success_iter - 1}.f1; f2 = history{success_iter - 1}.f2; f3 = history{success_iter - 1}.f3; f4 = history{success_iter - 1}.f4; f5 = history{success_iter - 1}.f5;
            J1 = history{success_iter - 1}.J1; J2 = history{success_iter - 1}.J2; J3 = history{success_iter - 1}.J3; J4 = history{success_iter - 1}.J4; J5 = history{success_iter - 1}.J5; 
            success_iter = success_iter - 1;
            disp('    ONE ITERATION IS REJECTED');
            disp(['    damping = ', num2str(damping)]);
            %close(findobj('type','figure','name', ['energy 1, iter ', num2str(settings.iter)]));
        end
    end
    
    %% Compute update
    I = eye(D * num_centers, D * num_centers);
   
    %% Apply update
    w5 = settings.w5;
    while true
        LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3) +  w4 * (J4' * J4) + w5 * (J5' * J5);
        rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3) + w4 * (J4' * f4) + w5 * (J5' * f5);
        delta = -  LHS \ rhs;
        
        [valid_update, new_poses, new_radii, change_indices] = apply_update(poses, blocks, radii, delta, D);
        if (valid_update), break; end
        w5 = w5 * 2; disp(num2str(w5));
        for p = 1:num_poses, poses{p} = compute_energy5(new_poses{p}, new_radii, blocks, settings); end
        [f5, J5] = assemble_energy(new_poses, num_centers, num_parameters, '5', settings);
    end
    %disp(['    update = ', num2str(delta')]);
    disp([w1 * (f1' * f1) + w2 * (f2' * f2) + w3 * (f3' * f3) +  w4 * (f4' * f4), ...
        w1 * (f1' * f1), w2 * (f2' * f2),  w3 * (f3' * f3), w4 * (f4' * f4)]);
    poses = new_poses; radii = new_radii;
    
    
end

% figure; hold on;
% plot(1:length(history), extractfield(history, 'f1')' * extractfield(history, 'f1') , 'linewidth', 2);
% plot(1:length(history), extractfield(history, 'f2')' * extractfield(history, 'f2'), 'linewidth', 2);
% plot(1:length(history),extractfield(history, 'f1')' * extractfield(history, 'f1') + extractfield(history, 'f2')' * extractfield(history, 'f2'), 'linewidth', 2);

save([absolute_path, 'rendering\history'], 'history');
%examine_history(settings, history);
%display_hand_sketch(poses, radii, blocks);
%display_result_convtriangles(poses{1}, blocks, radii, false); mypoints(pose.points, 'm'); drawnow;

