function [f1, J1, f2, J2] = compute_energy_arap(pose, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, display)
centers = pose.centers;
points = pose.points;
D = settings.D;

%% Compute projections
if settings.D == 2, [model_indices, pose.projections, pose.block_indices] = compute_projections_matlab(points, centers, blocks, radii); end
if settings.D == 3, [model_indices, pose.projections, pose.block_indices] = compute_projections(points, centers, blocks, radii); end
if settings.skeleton, [model_indices, pose.projections, pose.block_indices] = compute_skeleton_projections(points, centers, blocks); end

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


%% Translations energy
num_centers = length(centers);
num_blocks = length(blocks);
[f1, J1] = jacobian_arap(centers, radii, blocks, points, model_indices, points, D);
if settings.skeleton, [f1, J1] = jacobian_arap_skeleton(centers, points, model_indices, points, D); end    

%% Rotations energy
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

%% Display
if display, display_result_convtriangles(pose, blocks, radii, false); drawnow; end
