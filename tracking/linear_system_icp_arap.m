function [centers] = linear_system_icp_arap(centers, radii, blocks, model_points, offsets, block_indices, axis_projections, data_points, edge_indices, restpose_edges, solid_blocks, settings)

D = settings.D;
w1 = settings.w1;
w2 = settings.w2;

rotations = cell(length(blocks), 1);
edges = cell(length(blocks), 1);
edge_ids = zeros(0, 1);
k = 1;
for i = 1:length(edge_indices)
    edge_ids(i) = k;
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

for i = 1:length(solid_blocks)
    E = zeros(length(solid_blocks{i}), D);
    G = zeros(length(solid_blocks{i}), D);
    l = 1;
    for j = 1:length(solid_blocks{i})
        k = edge_ids(solid_blocks{i}(j));
        for e = 1:length(edge_indices{solid_blocks{i}(j)});
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
        k = edge_ids(solid_blocks{i}(j));
        for e = 1:length(edge_indices{solid_blocks{i}(j)})
            if length(solid_blocks{i}) > 1 || length(edge_indices{solid_blocks{i}(j)}) > 1
                rotations{k} = R;
            end
            k = k + 1;
        end
    end
end

%% Build ARAP system

U = zeros(D * length(data_points), D * length(centers));
for i = 1:length(data_points)
    if isempty(data_points{i}), continue; end
    if isempty(model_points{i}), continue; end
    
    for w = 1:length(blocks{block_indices{i}})
        for l = 1:D
            U(D * (i - 1) + l, D * (blocks{block_indices{i}}(w) - 1) + l) = offsets{i}.weights(w);
        end
    end
end
u = zeros(D * length(data_points), 1);
for i = 1:length(data_points)
    if isempty(data_points{i}), continue; end
    if isempty(model_points{i}), continue; end
    
    u(D * (i - 1) + 1: D * i) = data_points{i} - (model_points{i} - axis_projections{i});
end

B = zeros(D * length(restpose_edges), D * length(centers));
b = zeros(D * length(restpose_edges), 1);
k = 1;
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        for l = 1:D
            B(D * (k - 1) + l, D * (index2 - 1) + l) = 1;
            B(D * (k - 1) + l, D * (index1 - 1) + l) = -1;
        end
        b(D * (k - 1) + 1: D * k) = rotations{k} * restpose_edges{k};
        k = k + 1;
    end
end


% [U; B] * x = [u; b];
x = [w1 * U; w2 * B] \ [w1 * u; w2 * b];
disp([norm(w1 * U * x - w1 * u), norm(w2 * B * x - w2 * b)]);

for i = 1:length(centers)   
    centers{i} = x(D * (i - 1) + 1: D * i);
end


% myline(centers{1}, centers{1} + norm(restpose_edges{1}) * (previous_centers{2} - previous_centers{1}) / norm(previous_centers{2} - previous_centers{1}), 'g');
% myline(centers{1}, centers{1} + norm(restpose_edges{2}) * (previous_centers{3} - previous_centers{1}) / norm(previous_centers{3} - previous_centers{1}), 'g');
% myline(centers{2}, centers{2} + norm(restpose_edges{3}) * (previous_centers{3} - previous_centers{2}) / norm(previous_centers{3} - previous_centers{2}), 'g');
% 
% [model_points, axis_projections, ~, offsets] = update_attachments(centers, blocks, model_points, offsets, [1, 2, 3]);
% display_result(centers, data_points, model_points, blocks, radii, true, 0.3);
% mylines(data_points, model_points, [0.75, 0.75, 0.75]);
% mylines(axis_projections, model_points, [0.75, 0.75, 0.75]);
% display_skeleton(centers, radii, blocks, data_points, false);
% mypoints(axis_projections, 'r');
% view([100, -50]); camlight;
% drawnow;