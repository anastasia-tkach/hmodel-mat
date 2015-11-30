close all;
%clear;
D = 3; RAND_MAX = 32767;
w1 = 1; w2 = 50; damping = 0.1;
settings.w1 = w1; settings.w2 = w2;
settings.fov = 15;
downscaling_factor = 6;
settings.H = 480/downscaling_factor;
settings.W = 636/downscaling_factor;
settings.D = D;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
settings.side = 'front';
settings.view_axis = 'X';
closing_radius = 10;
num_samples = 3000;
mode = 'depth';

%% Generate data
[centers, radii, blocks] = get_random_convtriangle();
 edge_indices = {{[1, 2], [1, 3], [2, 3]}};
 radii{1} = radii{1} * 2;
%[centers, radii, blocks] = get_random_convsegment(D);
%edge_indices = {{[1, 2]}};

data_points = generate_convtriangles_points(centers, blocks, radii, num_samples);


%% Generate model
rotation_axis = randn(D, 1); rotation_angle = 0.3 * randn;
translation_vector = 0.1 * randn(D, 1);

% save centers centers; save radii radii; save blocks blocks; save data_points data_points;
% save rotation_axis rotation_axis; save rotation_angle rotation_angle; save translation_vector translation_vector;
% load centers; load radii; load blocks; load data_points;
% load rotation_axis; load rotation_angle; load translation_vector;

R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

data_bounding_box = compute_data_bounding_box(data_points);
solid_blocks = {[1]};
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end

attachments = cell(length(centers), 1);
parents = cell(length(centers), 1);
initial_centers = centers;
initial_data_points = data_points;
solid_blocks = {[1]};

%% Optimizaion
%close all;
centers = initial_centers;
data_points = initial_data_points;
global_frame_indices = blocks{1};

% i = randi([1, length(data_points)],1 , 4);
% data_points = data_points(i);

for iter = 1:1
    
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    switch mode
        case 'depth'
            [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
                       
            offsets = cell(length(model_points), 1);
            for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
            [offsets, ~] = initialize_attachments(centers, radii, blocks, model_points, offsets, global_frame_indices);
            
        case 'silhouette'
            [silh_data_points, silh_model_points, silh_data_normals, silh_model_indices, silh_block_indices] = ...
                compute_silhouette_projections(centers, blocks, radii, data_points, data_bounding_box, settings);
            
            silh_offsets = cell(length(silh_model_points), 1);
            for i = 1:length(silh_offsets), silh_offsets{i}.block_index = silh_block_indices{i}; end           
            [silh_offsets, ~] = initialize_attachments(centers, radii, blocks, silh_model_points, silh_offsets, global_frame_indices);
    end
    
    
    %% Fixed correspondences
    for inner_iter = 1:5
        
        switch mode
            case 'depth'
                [model_points, axis_projections, ~, offsets] = update_attachments(centers, blocks, model_points, offsets, global_frame_indices);
                
                %% Display
                display_result(centers, data_points, model_points, blocks, radii, false, 1);
                display_skeleton(centers, radii, blocks, [], false);
                 mylines(model_points, axis_projections, [0.75, 0.75, 0.75]);
                mylines(data_points, model_points, [0.75, 0.75, 0.75]);
                mypoints(data_points, [0.65, 0.1, 0.5]);
                mypoints(model_points, [0, 0.7, 1]);
                mypoints(axis_projections, 'r');
                camlight; drawnow;
                
                %% Linear system
                centers = linear_system_icp_arap(centers, radii, blocks, model_points, offsets, block_indices, axis_projections, ...
                    data_points, edge_indices, restpose_edges, solid_blocks, settings);
                
            case 'silhouette'                
                [silh_model_points, silh_axis_projections, ~, silh_offsets] = update_attachments(centers, blocks, silh_model_points, silh_offsets, global_frame_indices);
                
                %% Display
                display_result_convtriangles(centers, [], [], blocks, radii, true);
                %mylines(silh_data_points, silh_model_points, [0.75, 0.75, 0.75]);
                mypoints(silh_model_points, [0, 0.7, 1]);
                mypoints(data_points, [0.65, 0.1, 0.5]);
                mypoints(silh_data_points, 'm');
                view([-90, 0]); camlight; drawnow;
                
                %% Linear system
                centers = linear_system_icp_arap(centers, radii, blocks, silh_model_points, silh_offsets, silh_block_indices, silh_axis_projections, ...
                    silh_data_points, edge_indices, restpose_edges, solid_blocks, settings);
        end

    end
    
end

% %% Optimizaion
% centers = initial_centers;
%
% for iter = 1:1
%
%     [blocks] = reindex(radii, blocks);
%
%     %% Compute model_points
%     %[model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
%     [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
%
%     [silh_data_points, silh_model_points, silh_data_normals, silh_model_indices, silh_block_indices] = ...
%         compute_silhouette_projections(centers, blocks, radii, data_points, data_bounding_box, settings);
%
%     %% Display
%     %display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
%     %mypoints(data_points, [0.65, 0.1, 0.5]);
%     %mypoints(model_points, [0, 0.7, 1]);
%     %camlight; drawnow;
%
%     %% Compute projections locations
%     offsets = cell(length(model_points), 1);
%     for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
%     offsets = initialize_attachments(model_points, centers, blocks, offsets, global_frame_indices);
%
%     silh_offsets = cell(length(silh_model_points), 1);
%     for i = 1:length(silh_offsets), silh_offsets{i}.block_index = silh_block_indices{i}; end
%     silh_offsets = initialize_attachments(silh_model_points, centers, blocks, silh_offsets, global_frame_indices);
%
%     for inner_iter = 1:4
%
%         [model_points, ~, offsets] = update_attachments(model_points, centers, blocks, offsets, global_frame_indices);
%
%         [silh_model_points, ~] = update_attachments(silh_model_points, centers, blocks, silh_offsets, global_frame_indices);
%
%         %% Display 3D
%         %display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
%         %mylines(data_points, model_points, [0.75, 0.75, 0.75]);
%         %mypoints(data_points, [0.65, 0.1, 0.5]);
%         %mypoints(model_points, [0, 0.7, 1]);
%         %mypoints(axis_projections, 'r');
%         %camlight; drawnow;
%
%         %% Display silhouette
%         display_result_convtriangles(centers, data_points, [], blocks, radii, false);
%         %mylines(silh_data_points, silh_model_points, [0.75, 0.75, 0.75]);
%         mypoints(silh_model_points, [0, 0.7, 1]);
%         mypoints(data_points, [0.65, 0.1, 0.5]);
%         mypoints(silh_data_points, 'm');
%         view([-90, 0]); camlight; drawnow;
%
%         %% 3D term
%         %[f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
%
%         %% Silhouette term
%         [Fn, Jn] = jacobian_silhouette(centers, radii, blocks,  silh_model_points, silh_model_indices, silh_data_points, silh_data_normals, attachments, settings);
%
%         %% Rotations energy
%         [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments,parents);
%
%         %% Compute update
%         I = eye(D * length(centers), D * length(centers));
%         w1 = 1; w2 = 200; damping = 0.1;
%
%         %LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
%         %rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
%
%         LHS = damping * I + w1 * (Jn' * Jn) + w2 * (J2' * J2);
%         rhs = w1 * (Jn' * Fn) + w2 * (J2' * f2);
%
%         delta = - LHS \ rhs;
%
%         %energies(1) = w1 * (Fn' * Fn); energies(2) = w2 * (f2' * f2); disp(energies);
%
%         %% Apply update
%         for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
%
%     end
%
% end