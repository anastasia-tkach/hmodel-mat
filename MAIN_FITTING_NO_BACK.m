settings_default;
data_path = '_data/my_hand/trial1/';
%data_path = '_data/convtriangles/';

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
    poses{p}.invariants = compute_distance_invariants(poses{p}.centers, solids);
end

%poses = compute_closing_radius(poses, radii, settings);

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter;
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses        
        %% Data fitting energy
        poses{p} = compute_energy1(poses{p}, radii, blocks, settings, false);
        
        %% Silhouette energy
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, false);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);        
    end
    
    %% Shape consistency energy
    [f2, J2] = compute_energy2(poses, blocks, num_centers, settings);
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, num_centers, num_parameters, '1', settings);
    [f4, J4] = assemble_energy(poses, num_centers, num_parameters, '4', settings);
    [f5, J5] = assemble_energy(poses, num_centers, num_parameters, '5', settings);
    
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Apply update    
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w4 * (J4' * J4) +  w5 * (J5' * J5);
    rhs = w1 * J1' * f1 + w2 * J2' * f2 + w4 * J4' * f4 + w5 * J5' * f5;
    delta = -  LHS \ rhs;
    
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);

    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2); energies(3) = w4 * (f4' * f4); energies(4) = w5 * (f5' * f5); disp(energies);
    
    
end

for p = 1:length(poses)
    display_result_convtriangles(poses{p}.centers, poses{p}.points, poses{p}.projections, blocks, radii, false);
    display_skeleton(poses{p}.centers, radii, blocks, poses{p}.points, false);
end

results_path = '_data/my_hand/model/';
centers = poses{2}.centers;
save([results_path, 'centers.mat'], 'centers');
save([results_path, 'radii.mat'], 'radii');
save([results_path, 'blocks.mat'], 'blocks');
save([results_path, 'solids.mat'], 'solids');





