function [f, J] = energies_lsqnonlin(X, blocks, settings)

load poses;
load alpha;
load phalanges;
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


to_display = false;
if rem(iter, 100) == 1, to_display = true; end


%% Synchronize transfromations

if settings.energy7
    disp('DEAL WITH THE SHIFT');
    for p = 1:num_poses
        shift = poses{p}.centers{settings.names_map('palm_back')};
        for i = 1:length(poses{p}.centers)
            poses{p}.centers{i} = poses{p}.centers{i} - shift;
        end
        for i = 1:length(poses{p}.points)
            poses{p}.points{i} = poses{p}.points{i} - shift;
        end
    end
    [poses, alpha, phalanges] = synchronize_transformations(poses, radii, blocks, alpha, settings.names_map, settings.real_membrane_offset, true);
end


for p = 1:num_poses
    settings.p = p;
    
    %% Optimize theta
    [poses{p}.sync_centers, poses{p}.theta] = optimize_theta(poses{p}, radii, blocks, alpha, phalanges, settings.names_map, settings.real_membrane_offset, false);
    poses{p}.f7 = zeros(D * length(poses{p}.centers), 1);
    poses{p}.Jc7 = eye(D * length(poses{p}.centers), D * length(poses{p}.centers));
    poses{p}.Jr7 = zeros(D * length(poses{p}.centers), length(poses{p}.centers));
    for i = 1:length(poses{p}.centers)
       if ~isempty(poses{p}.sync_centers{i})
           poses{p}.f7(D * i - D + 1:D * i) = poses{p}.centers{i} - poses{p}.sync_centers{i};
       end
    end
    
    %% Data fitting energy
    poses{p} = compute_energy1_realsense(poses{p}, radii, blocks, settings, false);
    
    %% Silhouette energy
    poses{p} = compute_energy4_realsense(poses{p}, radii, blocks, settings, false);
    
    %% Building blocks existence energy
    poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
    
    %% Synch transformations energy
    %%{
    if settings.energy7
        poses{p}.f7 = zeros(D * length(poses{p}.centers), 1);
        poses{p}.Jc7 = eye(D * length(poses{p}.centers), D * length(poses{p}.centers));
        poses{p}.Jr7 = zeros(D * length(poses{p}.centers), length(poses{p}.centers));
        for i = 1:length(poses{p}.centers)
            if ~isempty(poses{p}.sync_centers{i})
                poses{p}.f7(D * i - D + 1:D * i) = poses{p}.centers{i} - poses{p}.sync_centers{i};
            end
        end
    end
    %%}
    
    %% Real length energy
    poses{p} = compute_energy8(poses{p}, settings);
end

%% Shape consistency energy
[f2, J2] = compute_energy2(poses, settings.solid_blocks, settings, false);

%% Assemble overall linear system
[f1, J1] = assemble_energy(poses, '1', settings);
[f4, J4] = assemble_energy(poses, '4', settings);
[f5, J5] = assemble_energy(poses, '5', settings);
%if settings.energy7
    settings.energy7 = true;
    [f7, J7] = assemble_energy(poses, '7', settings);
%end
[f8, J8] = assemble_energy(poses, '8', settings);

% f = [settings.w1 * f1; settings.w2 * f2; settings.w4 * f4; settings.w5 * f5; settings.w7 * f7; settings.w8 * f8];
% J = [settings.w1 * J1; settings.w2 * J2; settings.w4 * J4; settings.w5 * J5; settings.w7 * J7; settings.w8 * J8];
% disp([iter, settings.w1 * f1' * f1, settings.w2 * f2' * f2, settings.w4 * f4' * f4, settings.w5 * f5' * f5, settings.w7 * f7' * f7, settings.w8 * f8' * f8]);

f = [sqrt(settings.w1) * f1; sqrt(settings.w2) * f2; sqrt(settings.w4) * f4; sqrt(settings.w5) * f5];
J = [sqrt(settings.w1) * J1; sqrt(settings.w2) * J2; sqrt(settings.w4) * J4; sqrt(settings.w5) * J5];
%if settings.energy7
    f = [f; sqrt(settings.w7) * f7]; J = [J; sqrt(settings.w7) * J7];
    f = [f; sqrt(settings.w8) * f8]; J = [J; sqrt(settings.w8) * J8];
    
    f9 = zeros(num_poses * num_centers * D + num_centers, 1);
    J9 = zeros(num_poses * num_centers * D + num_centers, num_poses * num_centers * D + num_centers);
    J9(num_poses * num_centers * D + 1:end, num_poses * num_centers * D + 1:end) = 100;
    f = [f; f9]; J = [J; J9];
%end
disp([iter, settings.w1 * (f1' * f1), settings.w2 * (f2' * f2), settings.w4 * (f4' * f4), settings.w5 * (f5' * f5), settings.w7 * (f7' * f7), settings.w8 * (f8' * f8)]);

save X X;
save poses poses;
save alpha alpha;
save phalanges phalanges;
save iter iter;