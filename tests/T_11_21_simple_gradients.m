close all;
D = 2;
w1 = 1; w2 = 3; damping = 0.1;
[centers, radii, blocks] = get_random_convsegment(D);
[data_points] = get_transformed_points(centers, blocks, radii, 0.1, 2000);
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        k = k + 1;
    end
end

initial_centers = centers;
for iter = 1:5
    
    display_result_2D(centers, [], blocks, radii, false);
    display_skeleton(centers, radii, blocks, [], false);
    
    [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
    
    mylines(model_points, data_points, [0.7, 0.75, 0.8]);
    %mylines(model_points, axis_projections, [0.75, 0.75, 0.75]);
    mypoints(data_points, [0.65, 0.1, 0.5]);
    mypoints(model_points, [0, 0.7, 1]);
    
    %% Compute weights    
    W = zeros(D * length(data_points), D * length(centers));
    for i = 1:length(data_points)
        if length(model_indices{i}) == 1
            weights = 1;
        end
        if length(model_indices{i}) == 2
            P = [centers{model_indices{i}(1)}'; centers{model_indices{i}(2)}'; axis_projections{i}'];
            weights = [P(3,:),1]/[P(1:2,:),ones(2,1)];
        end
        for w = 1:length(model_indices{i})
            for l = 1:D
                W(D * (i - 1) + l, D * (model_indices{i}(w) - 1) + l) = weights(w);
            end
        end
    end
    
    %% Compute rotations
    rotations = cell(length(blocks), 1);
    edges = cell(length(blocks), 1);
    k = 1;
    for i = 1:length(edge_indices)
        for j = 1:length(edge_indices{i})
            e = restpose_edges{k};
            c = centers{edge_indices{i}{j}(1)};
            d = centers{edge_indices{i}{j}(2)};
            edges{k} = d - c;
            if D == 3
                rotations{k} = vrrotvec2mat(vrrotvec(e, d - c));
            end
            if D == 2
                theta = acos(e' * (d - c) / norm(e) / norm(d - c));
                if norm((d - c) / norm(d - c) - rotation(theta) * e / norm(e)) > 1e-10, theta = - theta; end
                rotations{k} = rotation(real(theta));
            end
            k = k + 1;
        end
    end
    %% Build ARAP system
    L = zeros(D * length(restpose_edges), D * length(centers));
    k = 1;
    for i = 1:length(edge_indices)
        for j = 1:length(edge_indices{i})
            index1 = edge_indices{i}{j}(1);
            index2 = edge_indices{i}{j}(2);
            for l = 1:D
                L(D * (i - 1) + l, D * (index2 - 1) + l) = 1;
                L(D * (i - 1) + l, D * (index1 - 1) + l) = -1;
            end
            k = k + 1;
        end
    end
    b = rotations{1} * (centers{2} - centers{1});
    
    u = zeros(D * length(data_points), 1);
    for i = 1:length(data_points)
        u(D * (i - 1) + 1: D * i) = data_points{i} - (model_points{i} - axis_projections{i});
    end
    
    % [L; W] * x = [b; u];
    x = [w1 * W; w2 * L] \ [w1 * u; w2 * b];
    
    for i = 1:length(centers)
        centers{i} = x(D * (i - 1) + 1: D * i);
    end
    
end

%% Previous approach

centers = initial_centers;
attachments = cell(length(centers), 1);
solid_blocks = {};
parents{1} = [];
previous_rotations{1} = eye(D, D);
for iter = 1:5
    
    display_result_2D(centers, [], blocks, radii, false);
    display_skeleton(centers, radii, blocks, [], false);
    
    [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
    
    mylines(model_points, data_points, [0.7, 0.75, 0.8]);
    %mylines(model_points, axis_projections, [0.75, 0.75, 0.75]);
    mypoints(data_points, [0.65, 0.1, 0.5]);
    mypoints(model_points, [0, 0.7, 1]);
    
    %% Translations energy
    [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
    
    %% Rotations energy
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
   
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
    
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    
end



