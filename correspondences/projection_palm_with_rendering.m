function [indices, projections, axis_projections, is_best_projection]  = projection_palm_with_rendering(centers, radii, blocks, data_points, camera_ray, camera_center, blocks_matrix, bounding_box, settings)

C = 50;

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
            tangent_points{count}.triangles = [];
            switch j
                case 1, tangent_points{count}.segments = [count + 1, count + 2];
                case 2, tangent_points{count}.segments = [count - 1, count + 1];
                case 3, tangent_points{count}.segments = [count - 2, count - 1];
            end
            count = count + 1;
        end
        
        n = tangent_points3D{i}.v1 - centers{blocks3D{i}(1)};
        if n' * camera_ray < 0
            blocks{count} = blocks3D{i};
            tangent_points{count} = tangent_points3D{i};
            tangent_points{count}.n = n/norm(n);
            for k = counts, tangent_points{k}.triangles = [tangent_points{k}.triangles; count]; end
            count = count + 1;
        end
        
        n = tangent_points3D{i}.u1 - centers{blocks3D{i}(1)};
        if n' * camera_ray < 0
            blocks{count} = -blocks3D{i};
            tangent_points{count} = tangent_points3D{i};
            tangent_points{count}.n = n/norm(n);
            for k = counts, tangent_points{k}.triangles = [tangent_points{k}.triangles; count]; end
            count = count + 1;
        end
    end
end

unique_indicator = ones(length(blocks), 1);
for i = 1:length(blocks)
    for j = i + 1:length(blocks)
        if length(blocks{i})  ~= length(blocks{j}), continue; end
        if all(blocks{i} == blocks{j})
            unique_indicator(j) = 0;
        end
    end
end
unique_indices = find(unique_indicator);

%% COMPUTE PROJECTION
RAND_MAX = 32767;
epsilon = 10e-9;
num_points = length(data_points);

indices = cell(num_points, 1);
projections = cell(num_points, 1);
axis_projections = cell(num_points, 1);
is_best_projection = ones(num_points, 1);

for i = 1:num_points
    
    p = data_points{i};
    min_distance = inf;
    min_front_facing_distance = inf;
    
    for u = 1:length(unique_indices)
        j = unique_indices(u);
        disp(blocks{j});
        
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
                continue;
            end
        end
        
        if length(blocks{j}) == 2
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            index1 = blocks{j}(1); index2 = blocks{j}(2);
            [index, q, s, is_inside] = projection_convsegment(p, c1, c2, r1, r2, index1, index2);
            n = q - s;
        end
        
        %% Check if a different part is rendered
        x = q(1) - bounding_box.min_x;
        x = x / (bounding_box.max_x - bounding_box.min_x);
        x = x * (settings.W - 1);     
        y = q(2) - bounding_box.min_y;
        y = y / (bounding_box.max_y - bounding_box.min_y);
        y = y * (settings.H - 1);
        W = blocks_matrix(floor(y):ceil(y), floor(x):ceil(x));
        
        current_w = 0;
        for k = 1:length(blocks{j})
            current_w = current_w * C + (abs(blocks{j}(k)) - 1);
        end
        if any(blocks{j} < 0), current_w = -current_w; end
        
        disp([num2str(j), ': ', num2str(q')]);
        mypoint(q, 'r'); drawnow;
        %disp(block_from_hash(w));
        if all(W ~= current_w)
            q = [inf; inf; inf];
        end
        
        %% Compute distance
        distance = norm(p - q);
        if is_inside == 1
            distance = - norm(p - q);
            if isinf(distance), distance = inf; end
        end
        
        %% Find min distance
        if distance < min_distance, min_distance = distance; end
        
        %% Check if front facing
        if camera_ray' * n > 0,
            continue;
        end
        
        if distance < min_front_facing_distance
            min_front_facing_distance = distance;
            indices{i} = index;
            projections{i} = q;
        end
        
        
    end
    % TODO deal with the case when inside of 2 blocks, no need to compute
    % insideness matrix, just look and all_insideness
    
    if isempty(indices{i})
        projections{i} = [inf; inf; inf];
        continue;
    end
    if abs(min_distance - min_front_facing_distance) > epsilon
        is_best_projection(i) = false;
    end
end
