% clear; clc; close all;
% settings.D = 3;
% D = settings.D;
% c1 = 7 * rand(D, 1);
% c2 = 7 * rand(D, 1);
% c3 = 7 * rand(D, 1);
% c4 = 7 * rand(D, 1);
% p = 7 * rand(D, 1);
% r1 = rand(1,  1);
% r2 = rand(1, 1);
% r3 = rand(1, 1);
% r4 = rand(1, 1);
% r5 = rand(1, 1);
% 
% num_points = 7;
% for i = 1:num_points
%     points{i} = 7 * rand(D, 1);
% end
c5 = c3 + c4 - c2;
%% Set up data structures

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

settings.skeleton = true;
blocks{1} = [1, 2];
blocks{2} = [2, 3, 4];
blocks{3} = [3, 4, 5];
centers = {c1; c2; c3; c4; c5};
radii = {r1; r2; r3; r4; r5};
solid_blocks = {1, [2, 3]};
[blocks] = reindex(radii, blocks);

%% Set up data structures
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

%% Optimization
iter = 0;
num_iter = 10;
history = cell(num_iter, 1);
while true
    %% Display
    if settings.skeleton
        [model_indices, projections, block_indices] = compute_skeleton_projections(points, centers, blocks);
        figure; hold on; axis equal; axis off;
        for i = 1:length(blocks)
            for j = 1:length(blocks{i})
                next = j + 1; if j == length(blocks{i}), next = 1; end
                myline(centers{blocks{i}(j)}, centers{blocks{i}(next)}, 'b');
                mypoint(centers{blocks{i}(j)}, 'b');
            end
        end
        mylines(points, projections, 'g');
        mypoints(points, 'k'); mypoints(projections, 'g');
    end
    
    if iter == num_iter, break; end
    iter = iter + 1;
    pose.centers = centers; pose.points = points;
    
    [f1, J1, f2, J2] = compute_energy_arap(pose, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, false);
    
    %% Solve
    I = 0.1 * eye(D * length(centers), D * length(centers));
    w1 = 1; w2 = 10;
    LHS = w1 * (J1' * J1) + w2 * (J2' * J2) + I;
    RHS = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = - LHS \ RHS;
    
    %% Apply update
    for o = 1:length(centers)
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    history{iter}.energy1 = w1 * f1' * f1;
    history{iter}.energy2 = w2 * f2' * f2;
    disp([w1 * f1' * f1 + w2 * f2' * f2, w1 * f1' * f1, w2 * f2' * f2]);
    
    
end


figure; hold on;
plot(1:length(history), extractfield(history, 'energy1'), 'linewidth', 2);
plot(1:length(history), extractfield(history, 'energy2'), 'linewidth', 2);
plot(1:length(history), extractfield(history, 'energy1') + extractfield(history, 'energy2'), 'linewidth', 2);





