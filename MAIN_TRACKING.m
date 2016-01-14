close all;
clear;
settings.mode = 'tracking';
settings_default;
settings.opengl = false; 
settings.skeleton = false;
settings.verbose = false;

input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
mode = 'my_hand';

%% Weights
damping = 100; num_iters = 50;
w1 = 1; w2 = 10; w3 = 100; w4 = 10; w5 = 2; w6 = 100;
%w1 = 0; w2 = 0; w3 = 0; w4 = 10; w5 = 0; w6 = 0;

load([input_path, 'data_points.mat']);
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']); 
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);

%% Display
display_htrack_hmodel(centers, radii, blocks, data_points, input_path, settings);

%% Semantic structures
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
[data_bounding_box, restpose_edges, edge_indices, previous_rotations, limits, adjacency_matrix] = setup_data_structures(centers, blocks, data_points, attachments);

%% Optimizaion
for iter = 1:num_iters
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
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
    
    %% Solve with gradients
    [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, elastic_blocks, D, previous_rotations, attachments, parents);
    [f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
    [f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, global_frame_indices, names_map, D);
    [f5, J5, outside_points] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
    [f6, J6] = existence_energy(centers, radii, blocks, attachments, settings);
    I = eye(D * length(centers), D * length(centers));
    w2 = 1.1088  * w2; 
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w3 * (J3' * J3) +  w4 * (J4' * J4) + w5 * (J5' * J5) + w6 * (J6' * J6);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2) +  w3 * (J3' * f3) + w4* (J4' * f4) + w5 * (J5' * f5) +  w6 * (J6' * f6);
    delta = -  LHS \ rhs;
    
    %% Display
    if settings.opengl
        display_opengl(centers, data_points, model_points, outside_points, blocks, radii, false, 1);
    else
        if settings.verbose 
            display_result(centers, data_points, model_points, blocks, radii, true, 0.7, 'big');
            mylines(data_points, model_points, [0.75, 0.75, 0.75]);
            mypoints(outside_points, 'y');
            view([180, -90]); camlight; drawnow;
        end
        if settings.skeleton
            figure; hold on; axis off; axis equal;
            display_skeleton(centers, radii, blocks, data_points, false, []); drawnow;
        end
    end
    
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    
    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2); energies(3) = w3 * (f3' * f3);
    energies(4) = w4 * (f4' * f4); energies(5) = w5 * (f5' * f5); energies(6) = w6 * (f6' * f6);
    history{iter + 1}.energies = energies; disp(energies);
    
    %display_shape_preservation(centers, edge_indices, restpose_edges);
end

%% Show results
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

if settings.opengl
    display_opengl(centers, [], [], [], blocks, radii, false, 1);
else
    display_result(centers, data_points, model_points, blocks, radii, false, 0.8, 'big');
    mypoints(data_points, [0.65, 0.1, 0.5]);
    view([180, -90]); camlight; drawnow;
end

%% Follow energies
display_energies(history, 'tracking')

