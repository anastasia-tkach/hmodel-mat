function [f2, J2] = jacobian_arap_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, attachments, D)


rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

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
        e = rotations{k} * restpose_edges{k};
        
        gradients = get_parameters_gradients([index1, index2], attachments, D);
        f2(D * (k - 1) + 1: D * k) = c - b - e;
        for l = 1:length(gradients)
            J2(D * (k - 1) + 1: D * k, D * (gradients{l}.index - 1) + 1:D * gradients{l}.index) = gradients{l}.dc2 - gradients{l}.dc1;
        end
        k = k + 1;
    end
end