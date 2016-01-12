function [centers] = find_htrack_model_nonrigid(centers, radii, blocks, htrack_centers, theta, names_map, named_blocks, key_points_names, verbose, D)

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

%% Create correspondences
p = cell(0, 1); q = cell(0, 1);
hmodel_indices = [1:3, 5:7, 9:11, 13:15, 17:19];
for i = 1:length(hmodel_indices)
    centers{hmodel_indices(i)} = htrack_centers{hmodel_indices(i)};
    p{i} = htrack_centers{hmodel_indices(i)};
    q{i} = centers{hmodel_indices(i)};
end
for i = 1:length(key_points_names)
    p{end + 1} = centers{names_map(key_points_names{i})};
    q{end + 1} = centers{names_map(key_points_names{i})};
    hmodel_indices = [hmodel_indices, names_map(key_points_names{i})];
end

figure; axis off; axis equal; hold on;
segments = create_ik_model('hand'); pose_ik_model(segments, theta, true, 'hand');
display_skeleton(centers, [], blocks, [], false, []);

%% Compute attachments
[attachments, global_frame_indices, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'my_hand', global_frame_indices, names_map, key_points_names);

%% Run ARAP
damping = 0.1; w1 = 1; w2 = 1;
I = eye(D * length(centers), D * length(centers));
%% Respore the shape
num_iters = 20;
for iter = 1:num_iters
    if rem(iter, 5) == 0
        a = 0.1;
        %display_shape_preservation(centers, edge_indices, restpose_edges);
    else
        a = 100;
    end
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'my_hand', global_frame_indices, names_map, key_points_names);
    [centers, axis_projections, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'my_hand', global_frame_indices, names_map, key_points_names);
    
    %% Display
    if verbose || iter == num_iters
        figure; axis off; axis equal; hold on;
        segments = create_ik_model('hand'); pose_ik_model(segments, theta, true, 'hand');
        display_skeleton(centers, radii, blocks, [], false, []);
        for i = 1:length(hmodel_indices), q{i} = centers{hmodel_indices(i)}; end
        for i = 1:length(attachments)
            if ~isempty(attachments{i}), myline(axis_projections{i}, centers{i}, 'g'); end
        end
        mylines(p, q, 'm');  mypoints(p, 'm'); drawnow;
    end
    
    %% Compute gradients
    for i = 1:length(hmodel_indices), q{i} = centers{hmodel_indices(i)}; end
    f1 = zeros(length(p) * D, 1); J1 = zeros(length(p) * D, length(centers) * D);
    for i = 1:length(p)
        index = hmodel_indices(i);
        gradients = get_parameters_gradients(index, attachments, D, 'tracking');
        f1(D * i - D + 1:D * i) = (q{i} - p{i});
        for j = 1:length(gradients)
            J1(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.dc1;
        end
    end
    [f2, J2, previous_rotations, parents, ~] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, elastic_blocks, D, previous_rotations, attachments, parents);
    LHS = damping * I + w1 * (J1' * J1) + a * w2 * (J2' * J2); rhs = w1 * (J1' * f1) + a * w2 * (J2' * f2);  delta = -  LHS \ rhs;
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
end