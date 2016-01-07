%% Generate data
close all; clear; clc;
D = 3;
num_samples = 1000;
epsilon = 0.01;
[centers, radii, blocks] = get_random_convsegment(D);
edge_indices = {{[1, 2]}};
radii{2} = radii{1} - epsilon;

data_points = generate_convtriangles_points(centers, blocks, radii, num_samples);

[model_indices, model_points, ~] = compute_projections(data_points, centers, blocks, radii);
data_points = model_points;
[normals] = compute_model_normals_temp(centers, blocks, radii, model_points, model_indices);


%% Remove the cap
for i = 1:length(data_points)
    if norm(centers{2} - data_points{i}) <= radii{2} + epsilon;
        data_points{i} = [];
        normals{i} = [];
    end
end
data_points = data_points(~cellfun('isempty', data_points));
normals = normals(~cellfun('isempty', normals));

%% Generate model
rotation_axis = randn(D, 1); rotation_angle = 0.1 * randn;
translation_vector = 0.05 * randn(D, 1);

R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

%% Save data
initial_centers = centers;
initial_radii = radii;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

centers = initial_centers;
radii = initial_radii;

%% Display
data_color = [0.65, 0.1, 0.5];
model_color = [0, 0.7, 1];
display_result(centers, [], [], blocks, radii, false, 0.7);
mypoints(data_points, data_color);
myvectors(data_points, normals, 0.1, [0.75, 0.75, 0.75]);
drawnow;

%% Initialize data structures
settings.mode = 'fitting';
settings_default;
downscaling_factor = 30;
settings.H = 480/downscaling_factor;
settings.W = 630/downscaling_factor;
num_iters = 10;
damping = 100; 
w1 = 0; w2 = 0; w4 = 1; w5 = 0;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; 
settings.w4 = w4; settings.w5 = w5;

[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = 1; p = 1;
poses = cell(num_poses, 1);
poses{p}.centers = centers;
poses{p}.points = data_points;
poses{p}.normals = normals;
for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    P = zeros(length(poses{p}.points), settings.D);
    for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
    poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
end

%% Fit
for iter = 1:num_iters
    settings.iter = iter;
        
    %% Data fitting energy
    poses{p} = compute_energy1(poses{p}, radii, blocks, settings, false);
    
    %% Silhouette energy
    poses{p} = compute_energy4(poses{p}, blocks, radii, settings, true);    
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, '1', settings);
    [f4, J4] = assemble_energy(poses, '4', settings);
        
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Apply update
    LHS = damping * I + w1 * (J1' * J1) + w4 * (J4' * J4);
    rhs = w1 * J1' * f1 + w4 * J4' * f4;
    delta = -  LHS \ rhs;
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    
    %% Keep track
    %energies = (f1' * f1); 
    energies = (f4' * f4) / length(f4); 
    disp(energies);
    history{iter + 1}.energies = energies;
end

%% Follow energies
num_energies = 1;
E = zeros(length(history)-1, num_energies);
for h = 2:length(history)
    for k = 1:num_energies
        E(h - 1, k) = history{h}.energies(k);
    end
end
figure; hold on; plot(2:length(history), log(E), 'lineWidth', 2);
