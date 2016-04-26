function [f, J] = energies_lsqnonlin(X, poses, radii, blocks, settings)

save X X;

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

%% Re-index
[blocks] = reindex(radii, blocks);
load iter;
iter = iter + 1;
to_display = false;
if rem(iter, 100) == 1, to_display = true; end
save iter iter;

%% Synchronize transfromations
for p = 1:num_poses
    shift = poses{p}.centers{settings.names_map('palm_back')};
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - shift;
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.points{i} - shift;
    end
end

load alpha;
[poses, alpha, phalanges] = synchronize_transformations(poses, radii, blocks, alpha, settings.names_map, false);
save alpha alpha; 
save phalanges phalanges;

for p = 1:num_poses
    settings.p = p;
    
    %% Data fitting energy
    poses{p} = compute_energy1_realsense(poses{p}, radii, blocks, settings, to_display);
    
    %% Silhouette energy
    poses{p} = compute_energy4_realsense(poses{p}, radii, blocks, settings, false);
    
    %% Building blocks existence energy
    poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
    
    %% Synch transformations energy
    poses{p}.f7 = zeros(D * length(poses{p}.centers), 1);
    poses{p}.Jc7 = eye(D * length(poses{p}.centers), D * length(poses{p}.centers));
    poses{p}.Jr7 = zeros(D * length(poses{p}.centers), length(poses{p}.centers));
    for i = 1:length(poses{p}.centers)
        if ~isempty(poses{p}.sync_centers{i})
            poses{p}.f7(D * i - D + 1:D * i) = poses{p}.centers{i} - poses{p}.sync_centers{i};
        end
    end
end

%% Shape consistency energy
[f2, J2] = compute_energy2(poses, settings.solid_blocks, settings, false);

%% Assemble overall linear system
[f1, J1] = assemble_energy(poses, '1', settings);
[f4, J4] = assemble_energy(poses, '4', settings);
[f5, J5] = assemble_energy(poses, '5', settings);
[f7, J7] = assemble_energy(poses, '7', settings);

f = [settings.w1 * f1; settings.w2 * f2; settings.w4 * f4; settings.w5 * f5; settings.w7 * f7];
J = [settings.w1 * J1; settings.w2 * J2; settings.w4 * J4; settings.w5 * J5; settings.w7 * J7];
disp([iter, f1' * f1, f2' * f2, f4' * f4, f5' * f5, f7' * f7]);

