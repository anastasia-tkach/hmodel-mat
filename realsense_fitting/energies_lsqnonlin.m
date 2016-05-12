function [f, J] = energies_lsqnonlin(X, blocks, settings)

load poses;
load initial_rotations;
load iter;
iter = iter + 1;
D = 3;
num_centers = settings.num_centers;
num_poses = length(poses);
for p = 1:num_poses
    c = X(D * num_centers * (p - 1) + 1:D * num_centers * p);
    for o = 1:num_centers
        poses{p}.centers{o} = c(D * o - D + 1:D * o);
    end
end
for o = 1:num_centers
    radii{o} = X(D * num_poses * num_centers + o);
end
f1 = 0; f2 = 0; f4 = 0; f5 = 0; f7 = 0; f8 = 0;

%% Re-index
[blocks] = reindex(radii, blocks);

for p = 1:num_poses
    settings.p = p;
    
    %% Optimize theta
    [poses{p}.sync_centers, poses{p}.theta, poses{p}.phalanges] = optimize_theta(poses{p}, radii, blocks, initial_rotations, settings.names_map, settings.real_membrane_offset, false);
    poses{p}.f7 = zeros(D * length(poses{p}.centers), 1);
    poses{p}.Jc7 = eye(D * length(poses{p}.centers), D * length(poses{p}.centers));
    poses{p}.Jr7 = zeros(D * length(poses{p}.centers), length(poses{p}.centers));
    for i = 1:length(poses{p}.centers)
       if ~isempty(poses{p}.sync_centers{i})
           poses{p}.f7(D * i - D + 1:D * i) = poses{p}.centers{i} - poses{p}.sync_centers{i};
       end
    end
    
    %% Data fitting energy
    poses{p} = compute_energy1_realsense(poses{p}, radii, blocks, settings, p, iter, true);
    
    %% Silhouette energy
    poses{p} = compute_energy4_realsense(poses{p}, radii, blocks, settings, false);
    
    %% Building blocks existence energy
    poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
    
    %% Real length energy
    poses{p} = compute_energy8(poses{p}, blocks);
end

%% Shape consistency energy
[f2, J2] = compute_energy2(poses, settings.solid_blocks, settings, false);

%% Assemble overall linear system
[f1, J1] = assemble_energy(poses, '1', settings);
[f4, J4] = assemble_energy(poses, '4', settings);
[f5, J5] = assemble_energy(poses, '5', settings);
settings.energy7 = true;
[f7, J7] = assemble_energy(poses, '7', settings);
[f8, J8] = assemble_energy(poses, '8', settings);
f9 = zeros(num_poses * num_centers * D + num_centers, 1);
J9 = eye(num_poses * num_centers * D + num_centers, num_poses * num_centers * D + num_centers);
J9(num_poses * num_centers * D + 1:end, num_poses * num_centers * D + 1:end) = 150 * eye(num_centers, num_centers);
% stop thumb bottom
%J9(num_poses * num_centers * D + settings.names_map('thumb_bottom'), num_poses * num_centers * D + settings.names_map('thumb_bottom')) = 1000;

%% Stack the energies together
f = [];
J = [];
f = [f; sqrt(settings.w1) * f1]; J = [J; sqrt(settings.w1) * J1];
f = [f; sqrt(settings.w2) * f2]; J = [J; sqrt(settings.w2) * J2];
f = [f; sqrt(settings.w4) * f4]; J = [J; sqrt(settings.w4) * J4];
f = [f; sqrt(settings.w5) * f5]; J = [J; sqrt(settings.w5) * J5];
f = [f; sqrt(settings.w7) * f7]; J = [J; sqrt(settings.w7) * J7];
f = [f; sqrt(settings.w8) * f8]; J = [J; sqrt(settings.w8) * J8];  
f = [f; sqrt(settings.w9) * f9]; J = [J; sqrt(settings.w9) * J9];

disp([iter, ...
    settings.w1 * (f1' * f1), ...
    settings.w2 * (f2' * f2), ...
    settings.w4 * (f4' * f4), ...
    settings.w5 * (f5' * f5), ...
    settings.w7 * (f7' * f7), ...
    settings.w8 * (f8' * f8)
    ]);

save X X;
save poses poses;
save iter iter;