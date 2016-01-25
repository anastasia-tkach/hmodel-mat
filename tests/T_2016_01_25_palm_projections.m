close all;
clc;
clear;
D = 3;

%% Synthetic model
[centers, radii, blocks] = get_random_convtriangle();
% [centers, radii, blocks] = get_random_convsegment(D);
%[centers, radii, blocks] = get_random_convquad();
data_points = generate_depth_data_synthetic(centers, radii, blocks);

camera_ray = [0; 0; 1];
camera_center = [0; 0; 0];


%% List the primitives
tangent_points3D = blocks_tangent_points(centers, blocks, radii);
blocks3D = blocks;
blocks = {}; tangent_points = {};
count = 1;

for i = 1:length(blocks3D)
    if length(blocks3D{i}) == 2
        blocks{count} = blocks3D{i};
        count = count + 1;
    end
    
    %% Check if front-facing
    if length(blocks3D{i}) == 3
        indices = nchoosek(blocks3D{i}, 2);
        index1 = indices(:, 1); index2 = indices(:, 2);
        counts = [count, count + 1, count + 2];
        
        for j = 1:length(index1)
            blocks{count} = [index1(j), index2(j)];
            tangent_points{count}.indices = [];
            count = count + 1;
        end
        
        n = centers{blocks3D{i}(1)} - tangent_points3D{i}.u1;
        if n' * camera_ray < 0
            blocks{count} = blocks3D{i};
            tangent_points{count} = tangent_points3D{i};
            tangent_points{count}.n = n/norm(n);
            for k = counts, tangent_points{k}.indices = [tangent_points{k}.indices; count]; end
            count = count + 1;
        end
        
        m = centers{blocks3D{i}(1)} - tangent_points3D{i}.v1;
        if m' * camera_ray < 0
            blocks{count} = -blocks3D{i};
            tangent_points{count} = tangent_points3D{i};
            tangent_points{count}.n = m/norm(m);
            for k = counts, tangent_points{k}.indices = [tangent_points{k}.indices; count]; end
            count = count + 1;
        end
    end
end

remove_indices = [];
for i = 1:length(blocks)
    for j = i + 1:length(blocks)
        if length(blocks{i})  ~= length(blocks{j}), continue; end
        if all(blocks{i} == blocks{j})
            remove_indices = [remove_indices, j];
        end
    end
end
blocks(remove_indices) = [];

%% Compute projections
RAND_MAX = 32767;
epsilon = 10e-9;
num_points = length(data_points);

indices = cell(num_points, 1);
projections = cell(num_points, 1);
axis_projections = cell(num_points, 1);
is_best_projection = zeros(num_points, 1);

for i = 1:num_points
    
    p = data_points{i};
    
    all_projections = cell(length(blocks), 1);
    all_distances = -RAND_MAX * ones(length(blocks), 1);
    all_indices = cell(length(blocks), 1);
    all_block_indices = zeros(length(blocks), 1);
    all_axis_projections = cell(length(blocks), 1);
    all_insideness = zeros(length(blocks), 1);
    
    min_distance = inf;
    min_front_facing_distance = inf;
    
    for j = 1:length(blocks)
        
        if length(blocks{j}) == 3
            if all(blocks{j} > 0)
                v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
            else
                v1 = tangent_points{j}.u1; v2 = tangent_points{j}.u2; v3 = tangent_points{j}.u3;
            end
            n = tangent_points{j}.n;
            distance = (p - v1)' * n;
            q = p - n * distance;
            if (is_point_in_triangle(q, v1, v2, v3));
                index = blocks{j};
                is_inside = false;
            else
                q = [inf; inf; inf];
            end
        end
        
        if length(blocks{j}) == 2
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            index1 = blocks{j}(1); index2 = blocks{j}(2);
            [index, q, s, is_inside] = projection_convsegment(p, c1, c2, r1, r2, index1, index2);
            
            %% Shadowing by a triangle
            for l = 1:length(tangent_points{j}.indices)
                k = tangent_points{j}.indices(l);
                v1 = tangent_points{k}.v1; v2 = tangent_points{k}.v2; v3 = tangent_points{k}.v3;
                [t, ~]  = ray_triangle_intersection (v1, v2, v3, q, -camera_ray);
                if ~any(isinf(t))
                    q = [inf; inf; inf];
                    break;
                end
            end
            n = q - s;
        end
        all_projections{j} = q;
        all_axis_projections{j} = s;
        all_distances(j) = norm(p - q);
        if is_inside == 1, all_distances(j) = - norm(p - q); end
        all_indices{j} = index;
        all_block_indices(j) = j;
        all_insideness(j) = is_inside;
        
        %% Find min distance
        if all_distances(j) < min_distance, min_distance = all_distances(j); end
        
        %% Check if front facing
        if camera_ray' * n > 0 ,
            all_distances(j) = inf;
            continue;
        end
        
        if all_distances(j) < min_front_facing_distance
            min_front_facing_distance = all_distances(j);
            indices{i} = index;
            projections{i} = q;
            block_indices{i} = j;
        end
    end
    % TODO deal with the case when inside of 2 blocks, no need to compute
    % insideness matrix, just look and all_insideness
    
    if isempty(indices{i})
        projections{i} = [inf; inf; inf];
        continue;
    end
    if abs(min_distance - min_front_facing_distance) < epsilon
        is_best_projection(i) = true;
    end
end

%% Display
display_result(centers, data_points, projections, blocks3D, radii, true, 1, 'big');
view([-180, -90]); camlight; drawnow;

