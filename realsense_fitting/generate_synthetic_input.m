%% Get initial model
%MANUAL_ADJUSTEMENT;

%% Get standard initial model
close all;
input_path = 'C:/Developer/data/models/anastasia/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
[~, dofs] = hmodel_parameters();
[centers, radii, blocks, ~, phalanges, mean_centers] = read_cpp_model(input_path);
for i = 1:length(phalanges), phalanges{i}.init_local = phalanges{i}.local; end
init_centers = centers;

theta = zeros(29, 1);
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
theta = zeros(29, 1); 
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);


%% Setup the parameters
settings.fov = 15;
downscaling_factor = 5;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = 3;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
num_theta = 29;
num_phalanges = 17;
%% Pose the model

num_poses = 3;
poses = cell(num_poses, 1);

for p = 1:num_poses
    theta = zeros(num_theta, 1);
    %theta(1:6) = randn(6, 1);
    if p == 1
        theta([14, 18, 22, 26]) = [pi/8, p/12, -pi/16, -pi/8];
    end
    if p == 2
        theta([14, 18, 22, 26]) = 0.2 * [pi/8, p/12, -pi/16, -pi/8];
    end
    if p == 3
        theta([14, 18, 22, 26]) = [-pi/9, -pi/60, pi/30, pi/9];
    end
    %theta(4:end) = -0.5 * rand(num_theta - 3, 1);
    for i = 1:length(phalanges), phalanges{i}.local = phalanges{i}.init_local; end
    phalanges = htrack_move(theta, dofs, phalanges);
    %data_centers = update_centers(centers, phalanges, names_map);
    [centers] = compute_joints_positions(centers, phalanges, theta, names_map, init_centers);
    
    %% Render model
    data_bounding_box = compute_model_bounding_box(centers, radii);
    [raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, 'Z', settings, 'front');
    rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
    [I, J] = find(rendered_model(:, :, 3) > - settings.RAND_MAX);
    points = cell(length(I), 1);
    for k = 1:length(I), points{k} = squeeze(rendered_model(I(k), J(k), :)); end
    
    %% Perturb
    theta = theta + 0.1 * rand(num_theta, 1);
    for i = 1:length(phalanges), phalanges{i}.local = phalanges{i}.init_local; end
    phalanges = htrack_move(theta, dofs, phalanges);
    %centers = update_centers(centers, phalanges, names_map);
    [centers] = compute_joints_positions(centers, phalanges, theta, names_map, init_centers);
    
    for i = 1:length(centers), centers{i} = centers{i} * 0.95; end
        
    %% Display 
    display_result(centers, [], [], blocks, radii, false, 1, 'big');
    mypoints(points, [0.6759, 0.2088, 0.46373]);
    view([-180, -90]); camlight; drawnow;
    
    %% Store
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.theta = theta;
    poses{p}.init_theta = theta;
    poses{p}.mean_centers = [0; 0; 0]; 
end

initial_rotations = cell(num_phalanges + 2, 1);
for i = 1:num_phalanges
    initial_rotations{i} = phalanges{i}.init_local;   
end
initial_rotations{18} = eye(4, 4);
initial_rotations{19} = eye(4, 4);

%[poses, alpha, phalanges] = synchronize_transformations(poses, radii, blocks, alpha, names_map, [18, 22, 22, 18], true);

%% Save
user_name = 'andrii';
stage = 1;

data_root = 'C:/Developer/data/MATLAB/';
save([data_root, '/stage.mat'],  'stage');

output_path = [data_root, user_name, '/stage', num2str(stage), '/'];
save([output_path, 'initial/poses.mat'], 'poses');
save([output_path, 'initial/radii.mat'], 'radii');
save([output_path, 'initial/blocks.mat'], 'blocks');
save([output_path, 'initial/initial_rotations.mat'], 'initial_rotations');

