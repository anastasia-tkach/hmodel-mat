settings_default; display_data = true;

%% Test: silhouette
data_path = '_data/my_hand/model/';
skeleton = false; mode = 'my_hand';

%% Weights
damping = 0.1; num_iters = 10;
w1 = 1; w2 = 50; w3 = 10000; w4 = 50; w5 = 10;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']); data_points = points;

data_path = '_data/my_hand/trial1/';
compute_attachments;
attachments = initialize_attachments(centers, centers, blocks, attachments, global_frame_indices);


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
for iter = 1:10
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    
    %% Display
    display_result_convtriangles(centers, data_points, model_points, blocks, radii, true); drawnow;
    %display_skeleton(centers, radii, blocks, data_points, false); drawnow;
    
    %% Compute projections locations
    offsets = cell(length(model_points), 1); for i = 1:length(offsets), offsets{i}.block_index = block_indices{i}; end
    [offsets, frames] = initialize_attachments(model_points, centers, blocks, offsets, global_frame_indices);
    
    for inner_iter = 1:5
        [model_points, frames, ~] = update_attachments(model_points, centers, blocks, offsets, global_frame_indices);
        
        %[centers, ~, attachments] = update_attachments(centers, centers, blocks, attachments, global_frame_indices);

        %% Display
        %display_result_convtriangles(centers, data_points, model_points, blocks, radii, true);
        %view([100, -50]); camlight; drawnow;
        %display_skeleton(centers, radii, blocks, data_points, false); drawnow;
        %factor = 0.5;
        %myline(centers{global_frame_indices(1)}, centers{global_frame_indices(1)} + factor *  frames{global_frame_block}(:, 1), 'm');
        %myline(centers{global_frame_indices(1)}, centers{global_frame_indices(1)} + factor *  frames{global_frame_block}(:, 2), 'm');
        %myline(centers{global_frame_indices(1)}, centers{global_frame_indices(1)} + factor *  frames{global_frame_block}(:, 3), 'm');
        %for i = 12:12
        %    myline(centers{blocks{i}(1)}, centers{blocks{i}(1)} + factor *  frames{i}(:, 1), 'g');
        %    myline(centers{blocks{i}(1)}, centers{blocks{i}(1)} + factor *  frames{i}(:, 2), 'g');
        %    myline(centers{blocks{i}(1)}, centers{blocks{i}(1)} + factor *  frames{i}(:, 3), 'g');
        %end
        %o = names_map('index_membrane');
        %rotation = find_svd_rotation(attachments{o}.frame, frames{attachments{o}.block_index});
        %p = attachments{o}.axis_projection + rotation' * attachments{o}.offset;
        %myline(attachments{o}.axis_projection, p, 'm');
        
        %% Translations energy
        [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
        
        %% Rotations energy
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
        
        %% Collisions energy
        %[f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
        
        %% Joint limits energy
        %[f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, mode, D);
        %[f4, J4] = jacobian_joint_limits(centers, previous_rotations, edge_indices, edge_ids, restpose_edges, initial_edges, parents, limits, attachments, D);
        
        %% Silhouette energy
        %[f5, J5] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
        
        %% Compute update
        I = eye(D * length(centers), D * length(centers));
        LHS = damping * I + w1 * (J1' * J1) + 10^inner_iter * w2 * (J2' * J2);
        rhs = w1 * (J1' * f1) + 10^inner_iter * w2 * (J2' * f2);
        
        delta = -  LHS \ rhs;
        
        %% Apply update
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        [centers, ~, attachments] = update_attachments(centers, centers, blocks, attachments, global_frame_indices);
        [centers, ~, attachments] = update_attachments(centers, centers, blocks, attachments, global_frame_indices);
        %energies(1) = w1 * (f1' * f1); energies(2) = 10^inner_iter * w2 * (f2' * f2); disp(energies);
        
        %disp('ITER');
        %for i = 1:length(blocks)
        %    disp([norm(centers{blocks{i}(2)} - centers{blocks{i}(1)}), norm(restpose_edges{i})]);
        %end
        
    end
    
    
end





