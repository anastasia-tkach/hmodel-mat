close all;
clear
D = 3; RAND_MAX = 32767;
settings.fov = 15;
downscaling_factor = 12;
settings.H = 480/downscaling_factor;
settings.W = 636/downscaling_factor;
settings.D = D;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
settings.side = 'front';
settings.view_axis = 'Z';
closing_radius = 10;
mode = 'synthetic';

%% Generate data
[centers, radii, blocks] = get_random_convtriangle();
edge_indices = {{[1, 2], [1, 3], [2, 3]}};

% [centers, radii, blocks] = get_random_convsegment(D);
% edge_indices = {{[1, 2]}};

data_bounding_box = compute_model_bounding_box(centers, radii);
model_points  = [];
[raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
camera_center = [0; 0; 1.5 * camera_center(3)];
rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);

[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));
N = length(model_points);
model_points = [model_points; cell(length(I), 1)];
for k = 1:length(I), model_points{N + k} = squeeze(rendered_model(I(k), J(k), :)); end
data_points = model_points;

%% Generate model
rotation_axis = randn(D, 1);
rotation_angle = 0.2 * randn;
translation_vector = - 0.5 * rand * [0; 0; 1];
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

%% Compute projections
close all;
attachments = cell(length(centers), 1); solid_blocks = []; parents = {[]};
damping = 0.1; num_iters = 10;
w1 = 1; w2 = 1; w3 = 100000; w4 = 50; w5 = 10;
global_frame_indices = [1, 2, 3];

restpose_edges = cell(length(blocks), 1); k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end

initial_centers = centers;

%% Optimization
centers = initial_centers;

for iter = 1:5
    [blocks] = reindex(radii, blocks);
    
    [model_indices, model_points, ~] = compute_tracking_projections(data_points, centers, blocks, radii,camera_center);
    
    %% Display
    display_result(centers, data_points, model_points, blocks, radii, true, 0.7); 
    mylines(data_points, model_points, [0.75, 0.75, 0.75]);
    view([177, -80]); camlight; drawnow;
    
    %% Solve with gradients
    [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
    
    model_normals = compute_model_normals_temp(model_points, centers, blocks, radii);
    [f1, J1, ~] = compute_normal_distance(centers, model_normals, f1, J1, [], D);
    
    I = eye(D * length(centers), D * length(centers));
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = -  LHS \ rhs;
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);

    [model_indices, model_points, block_indices] = compute_tracking_projections(data_points, centers, blocks, radii, camera_center);
    
    %% Compute projections locations
    offsets = cell(length(model_points), 1); for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
    [offsets, ~] = initialize_attachments(centers, radii, blocks, model_points, offsets, global_frame_indices);
    
    for inner_iter = 1:0
        [model_points, axis_projections, ~, offsets] = update_attachments(centers, blocks, model_points, offsets, global_frame_indices);
        
        %% Display
        display_result(centers, data_points, model_points, blocks, radii, true, 0.7);
        mylines(data_points, model_points, [0.75, 0.75, 0.75]);

        view([177, -80]); camlight; drawnow;
     
        %% Solve with gradients
        [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
     
        LHS = damping * I + w1 * (J1' * J1) + 100 * w2 * (J2' * J2);
        rhs = w1 * (J1' * f1) + 100 * w2 * (J2' * f2);
        delta = -  LHS \ rhs;
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);        
    end
end
