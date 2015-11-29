
clear;
settings_default; display_data = true;

%% Test: silhouette
data_path = '_data/my_hand/model/';
skeleton = false; mode = 'my_hand';

%% Weights
damping = 0.1; num_iters = 10;
w1 = 1; w2 = 1000; w3 = 10000; w4 = 50; w5 = 10;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']); data_points = points;

data_path = '_data/my_hand/trial1/';
compute_attachments;
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, global_frame_indices);


%% Reduce size

centers = centers([20, 19, 26, 25]);
radii = radii([20, 19, 26, 25]);
solid_blocks = {} ;
parents = {[2], []};
blocks = {[1, 2], [1, 3, 4]};
global_frame_indices = [1, 3, 4];
attachments = cell(length(centers), 1);
data_points = generate_convtriangles_points(centers, blocks, radii, 40000);
rotation_axis = randn(D, 1); rotation_angle = 0.6 * randn; translation_vector = 1 * randn(D, 1);
% save rotation_axis rotation_axis; save rotation_angle rotation_angle; save translation_vector translation_vector;
load rotation_axis; load rotation_angle; load translation_vector;

R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

%% Set up data structures
data_bounding_box = compute_data_bounding_box(data_points);

restpose_edges = cell(length(blocks), 1);
% initial_edges = cell(length(blocks), 1);
% edge_indices = {{[2, 1]}; {[3, 2]}; {[4, 3]}; {[6, 5]}; {[7, 6]}; {[8, 7]}; {[10, 9]}; {[11, 10]}; {[12, 11]}; {[14, 13]}; ...
%     {[15, 14]}; {[16, 15]}; {[18, 17]}; {[19, 18]}; {[20, 19]}; {[23, 21]; [21, 22]; [22, 23]}; {[23, 24]; [24, 22]; [23, 22]; }};
% limits = cell(length(blocks), 1);
% for i = 1:14
%     limits{i}.theta_min = [-pi/2, 0, -2 * pi];
%     limits{i}.theta_max = [pi/30, 0, 2 * pi];
%     if rem(i, 3) == 0, limits{i}.theta_min(2) = -pi/12; limits{i}.theta_max(2) = pi/12; end
%     if i == 3, limits{i}.theta_min(2) = -pi/24; limits{i}.theta_max(2) = pi/6; end
% end
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
% adjacency_matrix = zeros(length(blocks), length(blocks));
% for i = 1:length(blocks)-1
%     for j = i+1:length(blocks)
%         for k = 1:length(blocks{i})
%             if ismember(blocks{i}(k), blocks{j})
%                 adjacency_matrix(i, j) = 1;
%             end
%             if isempty(attachments{blocks{i}(k)}), continue; end
%             for l = 1:length(attachments{blocks{i}(k)}.indices)
%                 if ismember(attachments{blocks{i}(k)}.indices(l), blocks{j})
%                     adjacency_matrix(i, j) = 1;
%                 end
%             end
%         end
%     end
% end

%% Optimizaion
for iter = 1:1
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    
    %% Display
    display_result_convtriangles(centers, data_points, model_points, blocks, radii, true); view([100, -50]); camlight; drawnow; 
    return;
    %if iter == 2, break; end    
    
    %% Solve with gradients    
%     [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
%     [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
%     %[f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
%     %[f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, mode, D);
%     %[f5, J5] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
%     I = eye(D * length(centers), D * length(centers));
%     LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
%     rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
%     delta = -  LHS \ rhs;
%     for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
%     [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
%     [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);  
%     [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    
    %% Compute projections locations
    offsets = cell(length(model_points), 1); for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
    [offsets, frames] = initialize_attachments(centers, radii, blocks, model_points, offsets, global_frame_indices);
    
    for inner_iter = 1:5
        [model_points, axis_projections, frames, offsets] = update_attachments(centers, blocks, model_points, offsets, global_frame_indices);
        
        %% Display
        
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, true);
        view([100, -50]); camlight; drawnow;

        %% Solve without gradients
        settings.w2 = 10;
        centers = linear_system_icp_arap(centers, radii, blocks, model_points, offsets, block_indices, axis_projections, ...
            data_points, edge_indices, restpose_edges, solid_blocks, settings);
        
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        
        %energies(1) = w1 * (f1' * f1); energies(2) = 10^inner_iter * w2 * (f2' * f2); disp(energies);
        
        %% Examine length
        restpose_length = zeros(length(restpose_edges), 1);
        current_length = zeros(length(restpose_edges), 1);
        k = 1;
        for i = 1:length(edge_indices)
            for j = 1:length(edge_indices{i})
                index1 = edge_indices{i}{j}(1); index2 = edge_indices{i}{j}(2);
                current_length(k) = norm(centers{index2} - centers{index1}) / norm(restpose_edges{k});
                restpose_length(k) = 1;
                k = k + 1;
            end
        end
        figure; hold on; axis off; set(gcf,'color','w');
        stem(restpose_length, 'filled', 'color', [0, 0.7, 1], 'lineWidth', 2);
        stem(current_length, 'filled', 'color', [0.65, 0.1, 0.5], 'lineWidth', 2);
        ylim([0, 3]); drawnow;
        
    end
    
    
end






