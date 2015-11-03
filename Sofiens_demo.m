%settings_default;
%close all

%% Test: finger skeleton, rotated
D = 2; settings.D  = D;
data_path = '_data/htrack_model/skeleton_rotated/';
skeleton = true;

%% Weights
w1 = 1; w2 = 30; w3 = 30; damping = 0.1; num_iters = 50;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'solid_blocks.mat']);

%% Go to 2D
for i = 1:length(centers)
    centers{i} = centers{i}(1:2);
end
h_model = zeros(0, 1);
h_data = [];

%% Set up data structures
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(D, D);
        k = k + 1;
    end
end
attachments = cell(length(centers), 1);
%% Optimizaion
figure; axis equal; axis off; hold on; set(gcf,'color','white');
xlim([-70; 70]); ylim([-70; 70]);
%for t = 1:2
while true
      
    %% Display
    delete(h_model); h_model = zeros(0, 1);
    for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
        h_model(end + 1) = scatter(c1(1), c1(2), 100, [0.1, 0.4, 0.7], 'o', 'filled');
        h_model(end + 1) = scatter(c2(1), c2(2), 100, [0.1, 0.4, 0.7], 'o', 'filled');
        h_model(end + 1) = line([c1(1), c2(1)], [c1(2), c2(2)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
    end;
    [x, y, key] = ginput(1); data_points = {[x; y]};
    %if i == 1, data_points{1} = -70 + 140 * rand(D, 1); end
    h_data = scatter(data_points{1}(1), data_points{1}(2),  20, [0.9, 0.3, 0.5], 'o', 'filled' ); drawnow;
    xlim([-70; 70]); ylim([-70; 70]);
    
    for i = 1:num_iters          
        %% Translations energy
        [f1, J1] = jacobian_arap_translation_skeleton(centers, {centers{4}}, {4}, data_points, D);
        
        %% Rotations energy
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, ...
            edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, 'finger');

        [f3, J3] = jacobian_joint_limits(centers, previous_rotations, edge_indices, edge_ids, restpose_edges, parents, D);        
        
        %% Compute update
        J1(:, 1:2) = 0;
        J2(:, 1:2) = 0;
        I = eye(D * length(centers), D * length(centers));
        
        %LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
        %rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
        
        LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3);
        rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3);
        
        delta = -  LHS \ rhs;
        
        %% Apply update
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        
        disp(w1 * f1' * f1 + w2 * f2' * f2 + w3 * f3' * f3);
    end   
end





