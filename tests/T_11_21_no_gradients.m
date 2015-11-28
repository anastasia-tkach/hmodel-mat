close all; clear;
D = 3;
w1 = 1; w2 = 50; damping = 0.1;
settings.D = D; settings.w1 = w1; settings.w2 = w2;
%[centers, radii, blocks] = get_random_convsegment(D);
[centers, radii, blocks] = get_random_convtriangle();
if D == 2, num_samples = 2000; end
if D == 3, num_samples = 20000; end
[data_points] = get_transformed_points(centers, blocks, radii, 0.1, num_samples);
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
solid_blocks = {[1]};

initial_centers = centers;

centers = initial_centers;
for iter = 1:7
    
    [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
    
    %% Display
    if D == 2,
        display_result_2D(centers, [], blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
    end
    if D == 3
        display_result_convtriangles(centers, [], [], blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
    end
    
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
        if length(model_indices{i}) == 3
            model_indices{i} = abs(model_indices{i});
            P = [centers{model_indices{i}(1)}'; centers{model_indices{i}(2)}'; centers{model_indices{i}(3)}'; axis_projections{i}'];
            weights = [P(4,:),1]/[P(1:3,:),ones(3,1)];
        end
        for w = 1:length(model_indices{i})
            for l = 1:D
                W(D * (i - 1) + l, D * (model_indices{i}(w) - 1) + l) = weights(w);
            end
        end
    end
    
    %% Test weights
    %test_projections = cell(length(model_indices), 1);
    %for i = 1:length(model_indices)
    %    test_projections{i} = zeros(D, 1);
    %    for j = 1:length(model_indices{i})
    %        test_projections{i} = test_projections{i} + W(D * i, D * model_indices{i}(j)) * centers{model_indices{i}(j)};
    %    end
    %end
    %mypoints(test_projections, 'r');
    
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
    
    %% Compute solid rotations
    k = 1;
    for i = 1:length(solid_blocks)
        E = zeros(length(solid_blocks{i}), D);
        G = zeros(length(solid_blocks{i}), D);
        l = 1;
        s = k;
        for j = 1:length(solid_blocks{i})
            for e = 1:length(edge_indices{solid_blocks{i}(j)})
                E(l, :) = restpose_edges{k} / norm(restpose_edges{k});
                G(l, :) = edges{k} / norm(edges{k});
                l = l + 1;
                k = k + 1;
            end
        end
        S = E' * G;
        [U, ~, V] = svd(S);
        R = V * U';
        if det(R) < 0, U(:, D) = -  U(:, D); R = V * U'; end
        
        for j = 1:length(solid_blocks{i})
            for e = 1:length(edge_indices{solid_blocks{i}(j)})
                if length(solid_blocks{i}) > 1 || length(edge_indices{solid_blocks{i}(j)}) > 1
                    rotations{s} = R;
                end
                s = s + 1;
            end
        end
    end
    
    %% Build ARAP system
    L = zeros(D * length(restpose_edges), D * length(centers));
    b = zeros(D * length(restpose_edges), 1);
    k = 1;
    for i = 1:length(edge_indices)
        for j = 1:length(edge_indices{i})
            index1 = edge_indices{i}{j}(1);
            index2 = edge_indices{i}{j}(2);
            for l = 1:D
                L(D * (k - 1) + l, D * (index2 - 1) + l) = 1;
                L(D * (k - 1) + l, D * (index1 - 1) + l) = -1;
            end
            b(D * (k - 1) + 1: D * k) = rotations{k} * (centers{index2} - centers{index1});
            k = k + 1;
        end
    end        
    
    u = zeros(D * length(data_points), 1);
    for i = 1:length(data_points)
        u(D * (i - 1) + 1: D * i) = data_points{i} - (model_points{i} - axis_projections{i});
    end
    
    % [L; W] * x = [b; u];
    x = [w1 * W; w2 * L] \ [w1 * u; w2 * b];
        
    %[x] = linear_system_icp_arap(centers, radii, blocks, model_points, model_indices, axis_projections, data_points, edge_indices, restpose_edges, solid_blocks, settings);
    for i = 1:length(centers)
        centers{i} = x(D * (i - 1) + 1: D * i);
    end
    
    disp(norm([w1 * W; w2 * L] * x - [w1 * u; w2 * b]));
    
end

%% Previous approach

centers = initial_centers;
attachments = cell(length(centers), 1);
solid_blocks = {};
parents{1} = [];
previous_rotations{1} = eye(D, D);
for iter = 1:5
    
    [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
    
    %% Display
    if D == 2,
        display_result_2D(centers, [], blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
    end
    if D == 3
        display_result_convtriangles(centers, [], [], blocks, radii, false);
    end
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



