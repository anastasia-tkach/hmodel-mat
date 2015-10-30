settings_default;

% data_path = '_data/htrack_model/collision_finger/';
data_path = '_data/htrack_model/collision_palm/';
mode = 'hand';


%% Weights
w1 = 10;
w2 = 1;
damping = 0.1; num_iters = 8;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']); data_points = points;
load([data_path, 'attachments.mat']);
load([data_path, 'solid_blocks.mat']);

%% Set up data structures
edge_indices = cell(length(blocks), 1);
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

%% Build adjucency matrix
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

for iter = 1:3
    
    %% Display
    display_result_convtriangles(centers, [], [], blocks, radii, true);
    %display_blocks(centers, [], [], blocks, radii, false);
    campos([10, 160, -1500]); camlight; drawnow;
    
    [f1, J1] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings);
    
    %% Shape preservation
    [f2, J2, previous_rotations] = jacobian_arap_ik_rotation_attachment(centers, ...
        blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, mode);
    
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    for o = 1:length(attachments)
        if isempty(attachments{o}), continue; end
        attachments{o}.axis_projection = zeros(D, 1);
        for l = 1:length(attachments{o}.indices)
            attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
        end
        direction = (centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)}) / ...
            norm(centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)});
        rotation = vrrotvec2mat(vrrotvec(attachments{o}.direction, direction));
        centers{o} = attachments{o}.axis_projection + rotation * attachments{o}.offset;
    end
    
end
























