settings_default; display_data = true; %close all;

%% Test: finger skeleton, rotated
%data_path = '_data/htrack_model/skeleton_rotated/'; skeleton = true; mode = 'finger';
%% Test: finger skeleton, shifted
% data_path = '_data/htrack_model/skeleton_shifted/'; skeleton = true; mode = 'finger';
%% Test: finger skeleton, bent
% data_path = '_data/htrack_model/skeleton_bent/'; skeleton = true; mode = 'finger';
%% Test: finger skeleton, strongly bent
%data_path = '_data/htrack_model/skeleton_strongly_bent/'; skeleton = true; mode = 'finger';
%% Test: finger skeleton, shifted and bent
%data_path = '_data/htrack_model/skeleton_shifted_and_bent/'; skeleton = true; mode = 'finger';
%% Test: single finger
% data_path = '_data/htrack_model/finger_bent/'; skeleton = false; mode = 'finger';
%% Test: single finger
% data_path = '_data/htrack_model/finger_strongly_bent/'; skeleton = false; mode = 'finger';
%% Test: palm and finger
%data_path = '_data/htrack_model/palm_finger_strongly_bent/'; skeleton = false; mode = 'palm_finger';
%% Test: palm and finger with attachments
%data_path = '_data/htrack_model/palm_finger_offset/'; skeleton = false; mode = 'palm_finger';
%% Test: full hand with one slightly bent finger
%data_path = '_data/htrack_model/hand_finger_bent/'; skeleton = false; mode = 'hand';
%% Test: full hand with one strongly bent finger
%data_path = '_data/htrack_model/hand_one_finger/'; skeleton = false; mode = 'hand';
%% Test: full hand with all bent fingers
%data_path = '_data/htrack_model/hand_rest_pose/'; skeleton = false; mode = 'hand';
%% Test: full hand with bent middle finger
%data_path = '_data/htrack_model/hand_middle_finger/'; skeleton = false; mode = 'hand';
%% Test: full hand, two fingers bent
%data_path = '_data/htrack_model/hand_offset/'; skeleton = false; mode = 'hand';
%% Test: full hand, attachment
%data_path = '_data/htrack_model/hand_shifted/'; skeleton = false; mode = 'hand';

%% Test: full hand, shifted and articulated
% data_path = '_data/htrack_model/hand_shifted_articulated/';
% skeleton = false; mode = 'hand';

%% Test: collision between two fingers
% data_path = '_data/htrack_model/collision_palm/';
% skeleton = false; mode = 'hand'; collision_test = 1;

%% Test: joint limits
% data_path = '_data/htrack_model/joint_limits_hand/';
% skeleton = false; mode = 'hand';

%% Test: joint limits, full hand
% data_path = '_data/htrack_model/joint_limits_hand/';
% skeleton = true; mode = 'hand';

%% Test: silhouette
data_path = '_data/htrack_model/silhouette/';
skeleton = false; mode = 'hand';

%% Weights
damping = 0.1; w1 = 1; num_iters = 10;
if skeleton, w2 = 10; end
if ~skeleton && strcmp(mode, 'finger') w2 = 50; end
if ~skeleton && strcmp(mode, 'hand') w2 = 50; end
if exist('collision_test', 'var'), w1 = 0; w2 = 1; w3 = 10; num_iters = 2; display_data = false; end
w4 = 50; w3 = 10000; w5 = 10;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
%load([data_path, 'restpose_centers.mat']);
load([data_path, 'points.mat']); data_points = points;
load([data_path, 'attachments.mat']);
load([data_path, 'solid_blocks.mat']);

%% Set up data structures
data_bounding_box = compute_data_bounding_box(points);

edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
initial_edges = cell(length(blocks), 1);
switch mode
    case 'joint_limits'
        edge_indices = {{[2, 1]}, {[3, 2]}, {[4, 3]}, {[8, 6]}, {[5, 6]}, {[7, 8]}, {[5, 7]}};
    case 'hand'
        edge_indices = {{[2, 1]}; {[3, 2]}; {[4, 3]}; {[6, 5]}; {[7, 6]}; {[8, 7]}; {[10, 9]}; {[11, 10]}; {[12, 11]}; {[14, 13]}; ...
            {[15, 14]}; {[16, 15]}; {[18, 17]}; {[19, 18]}; {[20, 19]}; {[23, 21]; [21, 22]; [22, 23]}; {[23, 24]; [24, 22]; [23, 22]; }};
        
        if skeleton
            edge_indices = {{[2, 1]}; {[3, 2]}; {[4, 3]}; {[6, 5]}; {[7, 6]}; {[8, 7]}; {[10, 9]}; {[11, 10]}; {[12, 11]}; {[14, 13]}; ...
                {[15, 14]}; {[16, 15]}; {[18, 17]}; {[19, 18]}; {[20, 19]}; {[23, 21]}; {[23, 24]}; {[22, 24]}; {[21, 22]};};
        end
end

%% Set up joint limits
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
        %edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        %initial_edges{k} = restpose_centers{edge_indices{i}{j}(2)} - restpose_centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end

%% Descibe parrents
switch mode
    case 'finger'
        parents = {[], 1, 2};
    case 'palm_finger'
        parents = {2, 3, 4, [], []};
    case 'joint_limits'
        parents = {2, 3, 4, [], [], [], []};
    case 'hand'
        parents = {2, 3, 16, 5, 6, 16, 8, 9, 16, 11, 12, 16, 14, 15, 16, [], [], [], []};
    otherwise 
        parents = cell(length(blocks), 1);
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
for iter = 1:8
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    if skeleton
        [model_indices, model_points, block_indices] = compute_skeleton_projections(data_points, centers, blocks);
    else
        [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    end
    
    %% Display
    if skeleton
        figure; axis equal; axis off; hold on; set(gcf,'color','w');
        %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
            scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        end;
        mypoints(data_points, [0.9, 0.3, 0.5]);
        %campos([10, 160, -1500]); camlight; drawnow;
        view([-90, 0]);  camlight; drawnow;
    else
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
        %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        mypoints(data_points, [0.65, 0.1, 0.5]);
        mypoints(model_points, [0, 0.7, 1]);
        view([-180, -90]); camlight; drawnow;        
        %campos([10, 160, -1500]); camlight; drawnow;
    end
    
    %% Compute projections locations5
    offsets = cell(length(block_indices), 1);
    directions = cell(length(block_indices), 1);
    for i = 1:length(block_indices)
        if isempty(model_points{i}), continue; end
        c1 = centers{blocks{block_indices{i}}(1)}; c2 = centers{blocks{block_indices{i}}(2)};
        if skeleton, offsets{i} = norm(model_points{i} - c1) / norm(c2 - c1);
        else offsets{i} = model_points{i}  - c1; directions{i} = (c2 - c1) / norm(c2 - c1); end
    end
    
    for inner_iter = 1:4
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
%             %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
%             for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
%                 scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
%                 line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
%             end;
%             %mypoints(data_points, [0.9, 0.3, 0.5]);
%             %view([-90, 0]);  camlight; drawnow;
%             campos([10, 160, -1500]); camlight; drawnow;
%         else
%             display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
%             mypoints(data_points, [0.65, 0.1, 0.5]);
%             view([-180, -90]); camlight; drawnow;
%             %campos([10, 160, -1500]); camlight; drawnow;
%         end
        
        %% Translations energy
%         if skeleton
%            [f1, J1] = jacobian_arap_translation_skeleton_attachment(centers, model_points, model_indices, data_points, attachments, D);
%         else
%            %[f1, J1] = jacobian_arap_translation(centers, radii, blocks, data_points, model_indices, data_points, D);
%            [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
%         end
        
        %% Rotations energy
        %[f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
        
        %% Collisions energy
        %[f3, J3] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
        
        %% Joint limits energy
        %[f4, J4] = jacobian_joint_limits_new(centers, blocks, restpose_edges, previous_rotations, limits, parents, attachments, mode, D);
        %[f4, J4] = jacobian_joint_limits(centers, previous_rotations, edge_indices, edge_ids, restpose_edges, initial_edges, parents, limits, attachments, D);
        
        %% Silhouette energy
        [f5, J5] = silhouette_energy(centers, radii, blocks, data_points, data_bounding_box, settings);
        
        %% Compute update
        I = eye(D * length(centers), D * length(centers));
        
        %J1(:, 21 * (D - 1) + 1: end) = 0;
        %J2(:, 21 * (D - 1) + 1: end) = 0;
        %J4(:, 21 * (D - 1) + 1: end) = 0;
        
        %LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w3 * (J3' * J3) + w4 * (J4' * J4);
        %rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3) + w4 * (J4' * f4);
        
        %LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3);
        %rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3);
        
%         LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w4 * (J4' * J4);
%         rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w4 * (J4' * f4);
        
        %LHS = damping * I + w2 * (J2' * J2) + w4 * (J4' * J4);
        %rhs = w2 * (J2' * f2) + w4 * (J4' * f4);
        
        %LHS = damping * I + w2 * (J2' * J2) + w3 * (J3' * J3);
        %rhs = w2 * (J2' * f2) + w3 * (J3' * f3);
        
        LHS = damping * I + w2 * (J2' * J2) + w5 * (J5' * J5);
        rhs = w2 * (J2' * f2) + w5 * (J5' * f5);
        
        %LHS = damping * I + w2 * (J2' * J2)  + w4 * (J4' * J4) + w5 * (J5' * J5);
        %rhs = w2 * (J2' * f2) + w4 * (J4' * f4) + w5 * (J5' * f5);
        
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
    %disp(w1 * f1' * f1 + w2 * f2' * f2 + w4 * f4' * f4);
    %disp(' ');
    %disp(w2 * f2' * f2 + w4 * f4' * f4);
end




