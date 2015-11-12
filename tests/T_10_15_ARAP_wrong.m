clear; clc; close all;
settings.D = 2;
D = settings.D;
% c1 = 7 * rand(D, 1);
% c2 = 7 * rand(D, 1);
% c3 = 7 * rand(D, 1);
% r1 = rand(1,  1);
% r2 = rand(1, 1);
% r3 = rand(1, 1);
% p = 7 * rand(D, 1);
load c1; load c2; load c3; load p;
skeleton = true;

%% Set up data structures
blocks{1} = [1, 2];
blocks{2} = [2, 3];
centers = {c1; c2; c3};
%radii = {r1; r2; r3};
radii = {};

points{1} = c3 - [0; 1] * norm(c3 - c2);
points{2} = c3;
points{3} = c1;

base_indices = {2; 2; 2};
rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

%% Optimization
restpose = centers;
iter = 0;
num_iter = 10;
while true
    iter = iter + 1;
    
    if skeleton, [model_indices, projections, block_indices] = compute_skeleton_projections(points, centers, blocks, radii);
    else
        if settings.D == 2, [model_indices, projections, block_indices] = compute_projections_matlab(points, centers, blocks, radii); end
    end
    
%     figure; hold on; axis equal; axis off;
%     for i = 1:length(blocks)
%         myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'b');
%         for j = 1:length(blocks{i})
%             mypoint(centers{blocks{i}(j)}, 'b');
%         end
%     end
%     myline(points{1}, projections{1}, 'g');
%     mypoint(points{1}, 'm');  mypoint(points{2}, 'm');
%     mypoint(projections{1}, 'g');
    
    if (iter > num_iter), break; end
    
    %% Compute rotations
    edges = cell(length(blocks), 1);
    counts = zeros(length(blocks), 1);
    thetas = zeros(length(blocks), 1);
    for i = 1:length(points)
        c = centers{base_indices{model_indices{i}(1)}};
        p = points{i}; q = projections{i};
        theta = acos((p - c)' * (q - c) / norm(p - c) / norm(q - c));
        if norm((p - c) / norm(p - c) - rotation(theta) * (q - c) / norm(q - c)) > 1e-10
            theta = - theta;
        end
        thetas(block_indices{i}) = thetas(block_indices{i}) + theta;
        counts(block_indices{i}) = counts(block_indices{i}) + 1;
    end
    for i = 1:length(blocks)
        if counts(i) ~= 0
            thetas(i) = thetas(i) / counts(i);
        end
        edges{i} = rotation(thetas(i)) * (centers{blocks{i}(2)} - centers{blocks{i}(1)}) / ...
            norm(centers{blocks{i}(2)} - centers{blocks{i}(1)}) * norm(restpose{blocks{i}(2)} - restpose{blocks{i}(1)});
        if base_indices{blocks{i}(1)} ~= blocks{i}(1)
            edges{i} = -edges{i};        
        end
    end
    
    %% Draw rotations
    if iter == 1
    figure; hold on; axis equal; axis off;
    end
    for i = 1:length(blocks)
        myline(centers{base_indices{blocks{i}(1)}}, centers{base_indices{blocks{i}(1)}} + edges{i}, 'm');
        myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'b');
        for j = 1:length(blocks{i})
            mypoint(centers{blocks{i}(j)}, 'b');
        end
    end
    mylines(points, projections, 'g');
    mypoints(points, 'k'); mypoints(projections, 'g');
    if (iter == 1) xlimit = xlim; ylimit = ylim; end
    xlim(xlimit); ylim(ylimit);       
    
    
    %% Translations energy
    num_points = length(points);
    num_centers = length(centers);
    num_blocks = length(blocks);
    Fc = zeros(num_points * D, 1);
    Jc = zeros(num_points * D, num_centers * D);
    for i = 1:length(points)
        index = base_indices{model_indices{i}(1)};
        c = centers{index};
        p = points{i}; q = projections{i};
        d = q - c;
        Fc(D * (i - 1) + 1: D * i) = c + d - p;
        Jc(D * (i - 1) + 1: D * i, D * (index - 1) + 1:D * index) = eye(D, D);
    end
    
    %% Rotations energy
    Fr = zeros(num_blocks * D, 1);
    Jr = zeros(num_blocks * D, num_centers * D);
    for i = 1:length(blocks)
        for j = 1:length(blocks{i})
            if blocks{i}(j) == base_indices{blocks{i}(j)}
                index1 = blocks{i}(j);
                b = centers{blocks{i}(j)};
            else
                index2 = blocks{i}(j);
                c = centers{blocks{i}(j)};
            end
        end
        Fr(D * (i - 1) + 1: D * i) = c - b - edges{i};
        Jr(D * (i - 1) + 1: D * i, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        Jr(D * (i - 1) + 1: D * i, D * (index2 - 1) + 1:D * index2) = eye(D, D);
    end
    
    %% Solve
    I = 0.1 * ones(D * num_centers, 1);
    %I(1:D * num_blocks) = 0.1; I(D * num_blocks + 1:end) = 2;
    I = diag(I);
    wc = 1; wr = 1;
    LHS = wc * (Jc' * Jc) + wr * (Jr' * Jr) + I;
    RHS = wc * (Jc' * Fc) + wr * (Jr' * Fr);
    delta = - LHS \ RHS;
    
    %% Apply update
    for o = 1:length(centers)
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    
    %disp(wc * Fc' * Fc + wr * Fr' * Fr);
%     figure; axis equal; axis off; hold on;
%     for i = 1:length(blocks)       
%         myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'b');
%         for j = 1:length(blocks{i})
%             mypoint(centers{blocks{i}(j)}, 'b');
%         end
%     end
%     mypoint(points{1}, 'm');
%     centers{2}
waitforbuttonpress

end





