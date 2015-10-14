clear; clc; close all;
settings.D = 3;
D = settings.D;
c1 = 7 * rand(D, 1);
c2 = 7 * rand(D, 1);
c3 = 7 * rand(D, 1);
c4 = 7 * rand(D, 1);
p = 7 * rand(D, 1);
r1 = rand(1,  1);
r2 = rand(1, 1);
r3 = rand(1, 1);
r4 = rand(1, 1);
skeleton = false;
points{1} = p;
points{2} = p + randn(D, 1) / 10;

%% Set up data structures
blocks{1} = [1, 2];
blocks{2} = [2, 3, 4];
centers = {c1; c2; c3; c4};
radii = {r1; r2; r3; r4};

center_base_indices = {2; 2; 2; 2};
block_base_indices = {2; 2};
block_effector_indices = {[1]; [3, 4]};

%% Load real data
% settings_default;
% load([data_path, 'radii.mat']); load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
% load([data_path, 'solids.mat']); solids = [blocks; solids];

Rx  = @(x) [1, 0, 0; 0, cos(x), -sin(x); 0, sin(x), cos(x)];
Ry = @(x) [cos(x), 0, sin(x); 0, 1, 0; -sin(x), 0, cos(x)];
Rz = @(x) [cos(x), -sin(x), 0; sin(x), cos(x), 0; 0, 0, 1];
rotation = @(v) Rz(v(1)) * Ry(v(2)) * Rx(v(3));
block_edge_indices = cell(length(blocks), 1);
distances = cell(length(blocks), 1);
for i = 1:length(blocks)
    if length(blocks{i}) == 2,
        distances{i} = [norm(centers{block_effector_indices{i}(1)} - centers{block_base_indices{i}})];
        block_edge_indices{i}{1} = [block_base_indices{i}; block_effector_indices{i}(1)];
    end
    if length(blocks{i}) == 3,
        distances{i}(1) = norm(centers{block_effector_indices{i}(1)} - centers{block_base_indices{i}});
        block_edge_indices{i}{1} = [block_base_indices{i}; block_effector_indices{i}(1)];
        distances{i}(2) = norm(centers{block_effector_indices{i}(2)} - centers{block_base_indices{i}});
        block_edge_indices{i}{2} = [block_base_indices{i}; block_effector_indices{i}(2)];
    end
end

%% Optimization
restpose = centers;
[blocks] = reindex(radii, blocks);
iter = 0;
num_iter = 7;
while true
    iter = iter + 1;
    
    if skeleton, [model_indices, projections, block_indices] = compute_skeleton_projections(points, centers, blocks, radii);
    else
        if settings.D == 2, [model_indices, projections, block_indices] = compute_projections_matlab(points, centers, blocks, radii); end
        if settings.D == 3, [model_indices, projections, block_indices] = compute_projections_matlab(points, centers, blocks, radii); end
    end
    
    if (iter > num_iter), break; end
    
    %% Compute rotations
    edges = cell(length(blocks), 1);
    counts = zeros(length(blocks), 1);
    thetas = cell(length(blocks), 1);
    for i = 1:length(blocks), thetas{i} = zeros(D, 1); end
    for i = 1:length(points)
        c = centers{center_base_indices{abs(model_indices{i}(1))}};
        p = points{i}; q = projections{i};
        euler_anlges = rotm2eul(vrrotvec2mat(vrrotvec(q - c, p - c)));
        if norm((p - c) / norm(p - c) - rotation(euler_anlges) * (q - c) / norm(q - c)) > 1e-10
            euler_anlges = - euler_anlges;
        end
        thetas{block_indices{i}} = thetas{block_indices{i}} + euler_anlges';
        counts(block_indices{i}) = counts(block_indices{i}) + 1;
    end
    k = 1;
    for i = 1:length(block_edge_indices)
        if counts(i) ~= 0, thetas{i} = thetas{i} / counts(i); end
        for j = 1:length(block_edge_indices{i})
            edge = (centers{block_edge_indices{i}{j}(2)} - centers{block_edge_indices{i}{j}(1)}) / ...
                norm(centers{block_edge_indices{i}{j}(2)} - centers{block_edge_indices{i}{j}(1)});
            edges{k} = rotation(thetas{i}) * edge * distances{i}(j);
            k = k + 1;
        end
    end
    
    %% Draw rotations
    pose.centers = centers; pose.points = points; pose.projections = projections;
    display_result_convtriangles(pose, blocks, radii, true);
    k = 1;
    for i = 1:length(blocks)  
        for j = 1:length(block_edge_indices{i})
            myline(centers{block_edge_indices{i}{j}(1)}, centers{block_edge_indices{i}{j}(1)} + edges{k}, 'm');
            k = k + 1;
        end
        for j = 1:length(blocks{i})
            if j < length(blocks{i}), next = j + 1; else next = 1; end            
            myline(centers{blocks{i}(j)}, centers{blocks{i}(next)}, 'b');
            mypoint(centers{blocks{i}(j)}, 'b');
            
        end
    end
    %if (iter == 1) xlimit = xlim; ylimit = ylim; end
    %xlim(xlimit); ylim(ylimit);

    %% Translations energy
    num_points = length(points);
    num_centers = length(centers);
    num_blocks = length(blocks);
    Fc = zeros(num_points * D, 1);
    Jc = zeros(num_points * D, num_centers * D);
    for i = 1:length(points)
        index = center_base_indices{abs(model_indices{i}(1))};
        c = centers{index};
        p = points{i}; q = projections{i};
        d = q - c;
        Fc(D * (i - 1) + 1: D * i) = c + d - p;
        Jc(D * (i - 1) + 1: D * i, D * (index - 1) + 1:D * index) = eye(D, D);
    end
    
    %% Rotations energy
    Fr = zeros(num_blocks * D, 1);
    Jr = zeros(num_blocks * D, num_centers * D);
    k = 1;
    for i = 1:length(block_edge_indices)
        for j = 1:length(block_edge_indices{i})
            index1 = block_edge_indices{i}{j}(1);
            index2 = block_edge_indices{i}{j}(2);
            b = centers{index1}; c = centers{index2};            
            Fr(D * (k - 1) + 1: D * k) = c - b - edges{k};
            Jr(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
            Jr(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);            
            k = k + 1;
        end        
    end
    
    %% Solve
    I = 0.1 * ones(D * num_centers, D * num_centers);
    wc = 1; wr = 1;
    LHS = wc * (Jc' * Jc) + wr * (Jr' * Jr) + I;
    RHS = wc * (Jc' * Fc) + wr * (Jr' * Fr);
    delta = - LHS \ RHS;
    
    %% Apply update
    for o = 1:length(centers)
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    disp(wc * Fc' * Fc + wr * Fr' * Fr);
    waitforbuttonpress
    
end





