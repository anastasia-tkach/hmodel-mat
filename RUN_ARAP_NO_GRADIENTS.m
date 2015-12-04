
clear;
settings_default; display_data = true;
data_path = 'tracking/test4/';
skeleton = false; mode = 'my_hand';

%% Weights
damping = 1; num_iters = 10;
w1 = 1; w2 = 10; w3 = 100; w4 = 10; w5 = 2; w6 = 100;

%% Display initial model
load([data_path, 'theta.mat']);
load([data_path, 'data_points.mat']);

figure; axis off; axis equal; hold on;
segments = create_ik_model('hand');
[segments, joints] = pose_ik_model(segments, theta, false, 'hand');
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, 'hand');
display_result(centers, [], [], blocks, radii, false, 0.8);
mypoints(data_points, [0.65, 0.1, 0.5]);
view([180, -90]); camlight; drawnow;

%% Load data
load([data_path, 'radii.mat']); load([data_path, 'centers.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);

display_result(centers, [], [], blocks, radii, false, 0.9);
%display_skeleton(centers, radii, blocks, data_points, false);
view([180, -90]); camlight; drawnow;
return

data_path = '_data/my_hand/trial1/';
compute_attachments;
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, global_frame_indices);


%% Reduce size
%{
centers = centers([20, 19, 26, 25]);
radii = radii([20, 19, 26, 25]);
solid_blocks = {} ;
parents = {[2], []};
blocks = {[1, 2], [1, 3, 4]};
global_frame_indices = [1, 3, 4];
attachments = cell(length(centers), 1);

centers = centers([20, 26, 25]);
radii = radii([20, 26, 25]);
solid_blocks = {} ;
parents = {[]};
blocks = {[1, 2, 3]};
global_frame_indices = [1, 2, 3];
attachments = cell(length(centers), 1);

data_points = generate_convtriangles_points(centers, blocks, radii, 400000);
rotation_axis = randn(D, 1); rotation_angle = 0.6 * randn; translation_vector = 0.5 * randn(D, 1);
save rotation_axis rotation_axis; save rotation_angle rotation_angle; save translation_vector translation_vector;
load rotation_axis; load rotation_angle; load translation_vector;
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
   centers{i} = transform(centers{i}, R);
   centers{i} = transform(centers{i}, T);
end
%}

%% Set up data structures
data_bounding_box = compute_data_bounding_box(data_points);

restpose_edges = cell(length(blocks), 1);
limits = cell(length(blocks), 1);
for i = 1:14
    limits{i}.theta_min = [-pi/2, 0, -2 * pi];
    limits{i}.theta_max = [pi/30, 0, 2 * pi];
    if rem(i, 3) == 0, limits{i}.theta_min(2) = -pi/12; limits{i}.theta_max(2) = pi/12; end
    if i == 3, limits{i}.theta_min(2) = -pi/24; limits{i}.theta_max(2) = pi/6; end
end
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end

%% Build adjucency matrix
adjacency_matrix = zeros(length(blocks), length(blocks));
for i = 1:length(blocks)-1
    for j = i+1:length(blocks)
        for k = 1:length(blocks{i})
            if ismember(blocks{i}(k), blocks{j})
                adjacency_matrix(i, j) = 1;
            end
            if isempty(attachments{blocks{i}(k)}), continue; end
            for l = 1:length(attachments{blocks{i}(k)}.indices)
                if ismember(attachments{blocks{i}(k)}.indices(l), blocks{j})
                    adjacency_matrix(i, j) = 1;
                end
            end
        end
    end
end


% display_result(centers, [], [], blocks, radii, false, 0.8);
% mypoints(data_points, [0.65, 0.1, 0.5]);
% view([180, -90]); camlight; drawnow;

%% Optimizaion
for iter = 1:5
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [model_indices, model_points, ~] = compute_projections(data_points, centers, blocks, radii);
    model_normals = compute_model_normals_temp(centers, blocks, radii, model_points, model_indices);
    for i = 1:length(model_points)
        if isempty(model_points{i}), continue; end
        camera_ray = ([0; 0; 0] - model_points{i}) / norm([0; 0; 0] - model_points{i});
        if camera_ray' * model_normals{i} < 0
            model_points{i} = [];
            model_indices{i} = [];
        end
    end
    %[model_indices, model_points, ~] = compute_tracking_projections(data_points, centers, blocks, radii, [0; 0; 0]);
    
    %% Display
    display_result(centers, data_points, model_points, blocks, radii, true, 0.7);
    mylines(data_points, model_points, [0.75, 0.75, 0.75]);
    view([180, -90]); camlight; drawnow;
    
    %% Solve with gradients
    [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, elastic_blocks, D, previous_rotations, attachments, parents);
    [f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
    [f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, global_frame_indices, names_map, D);
    [f5, J5] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
    [f6, J6] = existence_energy(centers, radii, blocks, attachments, settings);
    I = eye(D * length(centers), D * length(centers));
    w2 = 1.5 * w2;
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w3 * (J3' * J3) +  w4 * (J4' * J4) + w5 * (J5' * J5) + w6 * (J6' * J6);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2) +  w3 * (J3' * f3) + w4* (J4' * f4) + w5 * (J5' * f5) +  w6 * (J6' * f6);
    delta = -  LHS \ rhs;
    
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    
    display_shape_preservation(centers, edge_indices, restpose_edges);
    
    %% Fixed correspondences
    %{
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    %[model_indices, model_points, block_indices] = compute_tracking_projections(data_points, centers, blocks, radii, [0; 0; 0]);
    model_normals = compute_model_normals_temp(centers, blocks, radii, model_points, model_indices);
    display_data_points = data_points;
    for i = 1:length(model_points)
        if isempty(model_points{i}), continue; end
        camera_ray = ([0; 0; 0] - model_points{i}) / norm([0; 0; 0] - model_points{i});
        if camera_ray' * model_normals{i} < 0
            model_points{i} = [];
            model_indices{i} = [];
            display_data_points{i} = [];
        end
    end
    
    %% Compute projections locations
    offsets = cell(length(model_points), 1); for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
    [offsets, ~] = initialize_attachments(centers, radii, blocks, model_points, offsets, global_frame_indices);
    
    for inner_iter = 1:0
        [model_points, axis_projections, ~, offsets] = update_attachments(centers, blocks, model_points, offsets, global_frame_indices);
        
        %% Display
        display_result(centers, display_data_points, model_points, blocks, radii, true, 0.7);
        mylines(display_data_points, model_points, [0.75, 0.75, 0.75]);
        %mylines(axis_projections, model_points, [0.75, 0.75, 0.75]);
        %display_skeleton(centers, radii, blocks, data_points, false);
        %mypoints(axis_projections, 'r');
        view([177, -80]); camlight; drawnow;
        
        %% Solve without gradients
        %settings.w2 = 100000;
        %centers = linear_system_icp_arap(centers, radii, blocks, model_points, offsets, block_indices, axis_projections, ...
        %data_points, edge_indices, restpose_edges, solid_blocks, settings);
        
        %% Solve with gradients
        [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
        %[f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
        %[f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, mode, D);
        %[f5, J5] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
        I = eye(D * length(centers), D * length(centers));
        LHS = damping * I + w1 * (J1' * J1) + 100 * w2 * (J2' * J2);
        rhs = w1 * (J1' * f1) + 100 * w2 * (J2' * f2);
        delta = -  LHS \ rhs;
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        
        %energies(1) = w1 * (f1' * f1); energies(2) = 10^inner_iter * w2 * (f2' * f2); disp(energies);
        %display_shape_preservation(centers, edge_indices, restpose_edges);        
    end
    %}
end

[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);

display_result(centers, data_points, model_points, blocks, radii, false, 0.8);
mypoints(data_points, [0.65, 0.1, 0.5]);
view([180, -90]); camlight; drawnow;



