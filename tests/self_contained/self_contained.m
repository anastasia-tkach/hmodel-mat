function [] = self_contained

clear; clc; D = 2;

%% Set parameters
w1 = 1; w2 = 30; w3 = 100; damping = 0.1; num_iters = 50;

%% Load data
load('radii.mat'); load('blocks.mat'); load('centers.mat');

%% Set up data structures
parents = {[], 1, 2};
limits = cell(length(blocks), 1);
for i = 1:length(blocks)
    limits{i}.theta_min = -pi/2;
    limits{i}.theta_max = 0; 
end
[restpose_edges, edge_indices] = compute_restpose_edges(centers, blocks);
I = eye(D * length(centers), D * length(centers));
figure; axis equal; axis off; hold on; xlim([-50; 60]); ylim([0; 70]); h_model = zeros(0, 1);

%% Optimizaion
while true
    
    %% Click the target
    [data_points, h_model] = set_target(centers, blocks, h_model);
    
    for i = 1:num_iters
        
        %% Fitting energy
        [f1, J1] = jacobian_icp(centers, {4}, data_points, D);
        
        %% Shape preservation energy
        [f2, J2] = jacobian_arap(centers, blocks, edge_indices, restpose_edges, D);
        
        %% Joint limits
        [f3, J3] = jacobian_joint_limits(centers, blocks, edge_indices, restpose_edges, restpose_edges, parents, limits, D);
        
        %% Fix the root point
        J1(:, 1:2) = 0; J2(:, 1:2) = 0; J3(:, 1:2) = 0;
        
        %% Compute update
        LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3);
        rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3);
        delta = -  LHS \ rhs;
        
        %% Apply update
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    end
end

end


function [F, J] = jacobian_joint_limits(centers, blocks, edge_indices, restpose_edges, initial_edges, parents, limits, D)

%% Compute current rotations
rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];
rotations = cell(length(blocks), 1);
edge_ids = zeros(0, 1);
k = 1;
for i = 1:length(edge_indices)
    edge_ids(i) = k;
    for j = 1:length(edge_indices{i})
        e = restpose_edges{k};
        c = centers{edge_indices{i}{j}(1)};
        d = centers{edge_indices{i}{j}(2)};   
        rotations{k} = rotation(real(vrrotvec2D(e, d - c))); 
        k = k + 1;
    end
end

%% Compute clamped rotations for joint limits
limits_rotations = cell(length(rotations), 1);
for i = 1:length(edge_indices)
    if isempty(parents{i}), continue; end
    
    parent_rotation = rotations{edge_ids(parents{i})};
    child_rotation =  rotations{edge_ids(i)};
    parent_edge = parent_rotation * restpose_edges{edge_ids(parents{i})};
    child_edge = child_rotation * restpose_edges{edge_ids(i)};
    
    G = rotation(vrrotvec2D(parent_edge, initial_edges{edge_ids(parents{i})}));
    rotated_parent_edge = G * parent_edge; rotated_child_edge = G * child_edge;
    
    theta = vrrotvec2D(rotated_parent_edge, rotated_child_edge);
    if theta > limits{i}.theta_min && theta < limits{i}.theta_max, continue; end
    
    theta_limited = max(theta, limits{i}.theta_min);
    theta_limited = min(theta_limited, limits{i}.theta_max);
    limits_rotations{edge_ids(i)} = G' * rotation(theta_limited) * rotation(theta)' * G * rotations{edge_ids(i)};
end

%% Build the joint limits jacobian
k = 0;
F = zeros(2, 1);
J = zeros(2, length(centers) * D);
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        k = k + 1;
        if isempty(limits_rotations{k}), continue; end
        
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        b = centers{index1}; c = centers{index2};
        e = limits_rotations{k} * restpose_edges{k};
        
        F(D * (k - 1) + 1: D * k) = c - b - e;
        J(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        J(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        
    end
end
end


function [F, J] = jacobian_icp(centers, model_indices, data_points, D)

num_points = length(data_points);
F = zeros(num_points * D, 1);
J = zeros(num_points * D, length(centers) * D);

for i = 1:num_points
    p = data_points{i};
    index =  model_indices{i};
    c1 = centers{index(1)};
    
    F(D * i - D + 1:D * i) = (c1 - p);
    J(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = eye(D, D);
end

end

function [F, J] = jacobian_arap(centers, blocks, edge_indices, restpose_edges, D)

num_centers = length(centers);
num_blocks = length(blocks);
k = 1;
F = zeros(num_blocks * D, 1);
J = zeros(num_blocks * D, num_centers * D);
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        b = centers{index1}; c = centers{index2};
        e = (c - b) / norm(c - b) * norm(restpose_edges{k});
        F(D * (k - 1) + 1: D * k) = c - b - e;
        J(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        J(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        k = k + 1;
    end
end

end

function [restpose_edges, edge_indices] = compute_restpose_edges(centers, blocks)
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        k = k + 1;
    end
end
end


function [data_points, h_model] = set_target(centers, blocks, h_model)

delete(h_model); h_model = zeros(0, 1);
for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
    h_model(end + 1) = scatter(c1(1), c1(2), 100, [0.1, 0.4, 0.7], 'o', 'filled');
    h_model(end + 1) = scatter(c2(1), c2(2), 100, [0.1, 0.4, 0.7], 'o', 'filled');
    h_model(end + 1) = line([c1(1), c2(1)], [c1(2), c2(2)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
end;
[x, y, ~] = ginput(1); data_points = {[x; y]};
scatter(data_points{1}(1), data_points{1}(2),  20, [0.9, 0.3, 0.5], 'o', 'filled' ); drawnow;
xlim([-50; 60]); ylim([0; 70]);

end


function [theta] = vrrotvec2D(a, b)

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];
theta = acos(a' * b / norm(a) / norm(b));
if norm(b / norm(b) - rotation(theta) * a / norm(a)) > 1e-10,
    theta = - theta; 
end
end










