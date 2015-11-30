function [f2, J2, previous_rotations] = jacobian_arap_ik_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, mode)

switch mode
    case 'finger'
    parents = {[], 1, 2};
    case 'palm_finger'
        parents = {2, 3, 4, [], []};
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
    if det(R) < 0, U(:, 3) = -  U(:, 3); R = V * U'; end
    
    for j = 1:length(solid_blocks{i})
        for e = 1:length(edge_indices{solid_blocks{i}(j)})
            if length(solid_blocks{i}) > 1
                rotations{s} = R;
            end
            s = s + 1;
        end
    end
end


%% Rotations energy

num_centers = length(centers);
num_blocks = length(blocks);
k = 1;
f2 = zeros(num_blocks * D, 1);
J2 = zeros(num_blocks * D, num_centers * D);
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        b = centers{index1}; c = centers{index2};
        
        if ~isempty(parents{i})
            previous_parent_rotation = previous_rotations{edge_ids(parents{i})};
            parent_rotation = rotations{edge_ids(parents{i})};
        else previous_parent_rotation = eye(3, 3);  parent_rotation = eye(3, 3);  
        end      
        
        e = previous_parent_rotation' * parent_rotation * rotations{k} * restpose_edges{k};
        f2(D * (k - 1) + 1: D * k) = c - b - e;
        J2(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        J2(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        k = k + 1;
    end
end

previous_rotations = rotations;