function [data_bounding_box, restpose_edges, edge_indices, previous_rotations, limits, adjacency_matrix] = setup_data_structures(centers, blocks, data_points, attachments)

%% Set up data structures
data_bounding_box = compute_data_bounding_box(data_points);

%% Joint limits
limits = cell(length(blocks), 1);
for i = 1:14
    limits{i}.theta_min = [-pi/2, 0, -2 * pi];
    limits{i}.theta_max = [pi/30, 0, 2 * pi];
    if rem(i, 3) == 0, limits{i}.theta_min(2) = -pi/12; limits{i}.theta_max(2) = pi/12; end
    if i == 3, limits{i}.theta_min(2) = -pi/24; limits{i}.theta_max(2) = pi/6; end
end

%% Restpose edges
k = 1;
restpose_edges = cell(length(blocks), 1);
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end

%% Adjucency matrix
adjacency_matrix = zeros(length(blocks), length(blocks));
for i = 1:length(blocks)-1
    for j = i+1:length(blocks)
        for k = 1:length(blocks{i})
            if ismember(blocks{i}(k), blocks{j})
                adjacency_matrix(i, j) = 1;
            end
            if isempty(attachments{blocks{i}(k)}), continue; end
            for l = 1:length(attachments{blocks{i}(k)}.indices)
                if ismember(attachments{blocks{i}(k)}.indices(l), blocks{j})
                    adjacency_matrix(i, j) = 1;
                end
            end
        end
    end
end