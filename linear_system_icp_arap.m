function [x] = linear_system_icp_arap(centers, radii, blocks, model_points, model_indices, axis_projections, data_points, edge_indices, restpose_edges, solid_blocks, settings)

D = settings.D;
w1 = settings.w1;
w2 = settings.w2;

%% Compute weights
W = zeros(D * length(data_points), D * length(centers));
for i = 1:length(data_points)
    if isempty(data_points{i}), continue; end
    
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
    if isempty(data_points{i}), continue; end
    u(D * (i - 1) + 1: D * i) = data_points{i} - (model_points{i} - axis_projections{i});
end

% [L; W] * x = [b; u];
x = [w1 * W; w2 * L] \ [w1 * u; w2 * b];