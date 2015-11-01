settings_default; display_data = true;

%% Test: finger skeleton, rotated
%data_path = '_data/htrack_model/skeleton_rotated/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted
% data_path = '_data/htrack_model/skeleton_shifted/';
% skeleton = true; mode = 'finger';

%% Test: finger skeleton, bent
% data_path = '_data/htrack_model/skeleton_bent/';
% skeleton = true; mode = 'finger';

%% Test: finger skeleton, strongly bent
%data_path = '_data/htrack_model/skeleton_strongly_bent/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted and bent
%data_path = '_data/htrack_model/skeleton_shifted_and_bent/';
%skeleton = true; mode = 'finger';

%% Test: single finger
% data_path = '_data/htrack_model/finger_bent/';
% skeleton = false; mode = 'finger';

%% Test: single finger
% data_path = '_data/htrack_model/finger_strongly_bent/';
% skeleton = false; mode = 'finger';

%% Test: palm and finger
%data_path = '_data/htrack_model/palm_finger_strongly_bent/';
%skeleton = false; mode = 'palm_finger';

%% Test: palm and finger with attachments
%data_path = '_data/htrack_model/palm_finger_offset/';
%skeleton = false; mode = 'palm_finger';

%% Test: full hand with one slightly bent finger
%data_path = '_data/htrack_model/hand_finger_bent/';
%skeleton = false; mode = 'hand';

%% Test: full hand with one strongly bent finger
%data_path = '_data/htrack_model/hand_one_finger/';
%skeleton = false; mode = 'hand';

%% Test: full hand with all bent fingers
%data_path = '_data/htrack_model/hand_rest_pose/';
%skeleton = false; mode = 'hand';

%% Test: full hand with bent middle finger
%data_path = '_data/htrack_model/hand_middle_finger/';
%skeleton = false; mode = 'hand';

%% Test: full hand, two fingers bent
%data_path = '_data/htrack_model/hand_offset/';
%skeleton = false; mode = 'hand';

%% Test: full hand, attachment
%data_path = '_data/htrack_model/hand_shifted/';
%skeleton = false; mode = 'hand';

%% Test: full hand, shifted and articulated
data_path = '_data/htrack_model/hand_shifted_articulated/';
skeleton = false; mode = 'hand';

%% Test: collision between two fingers
%data_path = '_data/htrack_model/collision_palm/';
%skeleton = false; mode = 'hand'; collision_test = 1;

%% Weights
damping = 0.1; w1 = 1; w3 = 0; num_iters = 15; 
if skeleton, w2 = 10; end
if ~skeleton && strcmp(mode, 'finger') w2 = 50; end
if ~skeleton && strcmp(mode, 'hand') w2 = 50; end
if exist('collision_test', 'var'), w1 = 0; w2 = 1; w3 = 10; num_iters = 2; display_data = false; end

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']); data_points = points;
load([data_path, 'attachments.mat']);
load([data_path, 'solid_blocks.mat']);

%% Set up data structures
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
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

%% Optimizaion
for iter = 1:num_iters
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    if skeleton
        [model_indices, model_points, block_indices] = compute_skeleton_projections(data_points, centers, blocks);
    else
        [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    end
    
    %% Display
    if skeleton
        figure; axis equal; axis off; hold on; set(gcf,'color','white');
        %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
            scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        end; %mypoints(data_points, [0.9, 0.3, 0.5]);view(90, 0); drawnow;
    else
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, display_data);
        %view([-90, 0]); camlight; drawnow;
        campos([10, 160, -1500]); camlight; drawnow;
    end
    
    %% Compute projections locations
    offsets = cell(length(block_indices), 1);
    directions = cell(length(block_indices), 1);
    for i = 1:length(block_indices)
        if isempty(model_points{i}), continue; end
        c1 = centers{blocks{block_indices{i}}(1)}; c2 = centers{blocks{block_indices{i}}(2)};
        if skeleton, offsets{i} = norm(model_points{i} - c1) / norm(c2 - c1);
        else offsets{i} = model_points{i}  - c1; directions{i} = (c2 - c1) / norm(c2 - c1); end
    end
    
    for inner_iter = 1:5
        for i = 1:length(block_indices)
            if isempty(model_points{i}), continue; end
            c1 = centers{blocks{block_indices{i}}(1)}; c2 = centers{blocks{block_indices{i}}(2)};
            if skeleton, model_points{i} = c1 + offsets{i} * (c2 - c1);
            else
                direction = (c2 - c1) / norm(c2 - c1);
                rotation = vrrotvec2mat(vrrotvec(directions{i}, direction));
                model_points{i} = c1 + rotation * offsets{i};
            end
        end
        
        %% Display
        %         if skeleton
        %             figure; axis equal; axis off; hold on; set(gcf,'color','white');
        %             mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        %             for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
        %                 scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
        %                 line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        %             end; mypoints(data_points, [0.9, 0.3, 0.5]);view(90, 0); drawnow;
        %         else
        %             display_result_convtriangles(centers, data_points, model_points, blocks, radii, true);
        %             view([-90, 0]); drawnow;
        %             %campos([10, 160, -1500]); camlight;
        %         end
        
        %% Translations energy
        if skeleton
            [f1, J1] = jacobian_arap_translation_skeleton_attachment(centers, model_points, model_indices, data_points, attachments, D);
        else
            %[f1, J1] = jacobian_arap_translation(centers, radii, blocks, data_points, model_indices, data_points, D);
            [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
        end
        
        %% Rotations energy
        %[f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
        [f2, J2, previous_rotations] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, mode);
        
        %% Collisions eneryg
        [f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
        
        %% Compute update
        I = eye(D * length(centers), D * length(centers));
        LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3);
        rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3);
        delta = -  LHS \ rhs;
        
        %% Apply update
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        for o = 1:length(attachments)
            if isempty(attachments{o}), continue; end
            attachments{o}.axis_projection = zeros(D, 1);
            %centers{o} = zeros(D, 1);
            for l = 1:length(attachments{o}.indices)
                attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
                %centers{o} = centers{o} + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
            end
            direction = (centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)}) / ...
                norm(centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)});
            rotation = vrrotvec2mat(vrrotvec(attachments{o}.direction, direction));
            centers{o} = attachments{o}.axis_projection + rotation * attachments{o}.offset;
        end
        
        
    end
    %for i = 1:length(blocks)
    %disp([norm(centers{blocks{i}(2)} - centers{blocks{i}(1)}), norm(restpose_edges{i})]);
    %end
    disp(w1 * f1' * f1 + w2 * f2' * f2 + w3 * f3' * f3);
    %disp(' ');
end





