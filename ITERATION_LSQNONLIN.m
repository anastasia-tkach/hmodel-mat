function [f, J] = ITERATION_LSQNONLIN(X, blocks)

load poses;
load settings;
settings.iter = settings.iter + 1;
save(['X', num2str(settings.iter)], 'X');

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
[blocks] = reindex(radii, blocks);

for p = 1:num_poses
    settings.p = p;
    %% Data fitting energy
    poses{p} = compute_energy1(poses{p}, radii, blocks, settings, p, false);
    
    %% Silhouette energy
    poses{p} = compute_energy4(poses{p}, blocks, radii, settings, false);
    
    %% Building blocks existence energy
    poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
    
end

%% Shape consistency energy
[f2, J2] = compute_energy2(poses, settings.solid_blocks, settings, false);

%% Assemble overall linear system
[f1, J1] = assemble_energy(poses, '1', settings);
[f4, J4] = assemble_energy(poses, '4', settings);
[f5, J5] = assemble_energy(poses, '5', settings);

%% Apply update
%settings.w4 = 10 * length(f1) / length(f4);
settings.w2 = settings.w2 * 2;

f = [sqrt(settings.w1) * f1; sqrt(settings.w2) * f2; sqrt(settings.w4) * f4; sqrt(settings.w5) * f5];
J = [sqrt(settings.w1) * J1; sqrt(settings.w2) * J2; sqrt(settings.w4) * J4; sqrt(settings.w5) * J5];  
f9 = zeros(num_poses * num_centers * D + num_centers, 1);
J9 = 1 * eye(num_poses * num_centers * D + num_centers, num_poses * num_centers * D + num_centers);
J9(num_poses * num_centers * D + 1:end, num_poses * num_centers * D + 1:end) = 3 * eye(num_centers, num_centers);
f = [f; f9]; J = [J; J9];

disp([settings.iter, settings.w1 * (f1' * f1), settings.w2 * (f2' * f2), settings.w4 * (f4' * f4), settings.w5 * (f5' * f5)]);

energies(1) = settings.w1 * (f1' * f1); energies(2) = settings.w2 * (f2' * f2);
energies(4) = settings.w4 * (f4' * f4); energies(5) = settings.w5 * (f5' * f5);
settings.history{settings.iter}.energies = energies;

%% Save data
save X X;
save poses poses;
save settings settings;
