function [f2, J2, previous_rotations] = jacobian_arap_rotation_joint_limits(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, mode)

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

switch mode
    case 'finger'
        parents = {[], 1, 2};
    case 'hand'
        parents = {2, 3, 16, 5, 6, 16, 8, 9, 16, 11, 12, 16, 14, 15, 16, [], [], 16, 16, 16, 16, 16};
end
edge_ids = zeros(0, 1);

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
        edge_ids(i) = k;
        k = k + 1;
    end
end

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
    for j = 1:length(solid_blocks{i})
        for e = 1:length(edge_indices{solid_blocks{i}(j)})
            if length(solid_blocks{i}) > 1
                rotations{s} = R;
            end
            s = s + 1;
        end
    end
end

%% Joint limits

for i = 1:length(edge_indices)
    if isempty(parents{i}), continue; end
    parent_rotation = rotations{edge_ids(parents{i})};
    child_rotation =  rotations{edge_ids(i)};
    parent_edge = parent_rotation * restpose_edges{edge_ids(parents{i})};
    child_edge = child_rotation * restpose_edges{edge_ids(i)};
    
    if D == 2
        theta = acos(parent_edge' * child_edge / norm(parent_edge) / norm(child_edge));
        if norm(child_edge / norm(child_edge) - rotation(theta) * parent_edge / norm(parent_edge)) > 1e-10, theta = - theta; end
        if theta > 0.01
            disp(theta)
            rotations{edge_ids(i)} = rotations{edge_ids(parents{i})};
            
            parent_rotation = rotations{edge_ids(parents{i})};
            child_rotation =  rotations{edge_ids(i)};
            parent_edge = parent_rotation * restpose_edges{edge_ids(parents{i})};
            child_edge = child_rotation * restpose_edges{edge_ids(i)};
            theta = acos(parent_edge' * child_edge / norm(parent_edge) / norm(child_edge));
        end
    end
    
end

%% Rotations energy

num_centers = length(centers);%
num_blocks = length(blocks);
k = 1;
f2 = zeros(num_blocks * D, 1);
J2 = zeros(num_blocks * D, num_centers * D);
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        b = centers{index1}; c = centers{index2};
        e = rotations{k} * restpose_edges{k};
        f2(D * (k - 1) + 1: D * k) = c - b - e;
        J2(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        J2(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        k = k + 1;
    end
end

previous_rotations = rotations;
