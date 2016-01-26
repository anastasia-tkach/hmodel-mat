function [indices, projections, axis_projections, is_best_projection]  = projection_palm(centers, radii, blocks, data_points, camera_ray, camera_center)

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
            %mypoint(q, 'r');
        end
        
        if length(blocks{j}) == 2
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            index1 = blocks{j}(1); index2 = blocks{j}(2);
            [index, q, s, is_inside] = projection_convsegment(p, c1, c2, r1, r2, index1, index2);
            %mypoint(q, 'g');
            %% Shadowing by a triangle
            if ~isempty(tangent_points) && ~isempty(tangent_points{j})
                for l = 1:length(tangent_points{j}.triangles)
                    k = tangent_points{j}.triangles(l);
                    if all(blocks{k} > 0)
                        v1 = tangent_points{k}.v1; v2 = tangent_points{k}.v2; v3 = tangent_points{k}.v3;
                    else
                        v1 = tangent_points{k}.u1; v2 = tangent_points{k}.u2; v3 = tangent_points{k}.u3;
                    end
                    o = q - camera_ray' * (q - camera_center) * camera_ray;
                    [t, ~]  = ray_triangle_intersection (v1, v2, v3, o, camera_ray);
                    if ~any(isinf(t))
                        min_distance = min(min_distance, norm(q - p));
                        q = [inf; inf; inf];                       
                        break;
                    end
                end
                for l = 1:length(tangent_points{j}.segments)
                    k = tangent_points{j}.segments(l);
                    c1 = centers{blocks{k}(1)}; c2 = centers{blocks{k}(2)};
                    r1 = radii{blocks{k}(1)}; r2 = radii{blocks{k}(2)};
                    o = q - camera_ray' * (q - camera_center) * camera_ray;
                    [t, ~] = ray_convsegment_intersection(c1, c2, r1, r2, o, camera_ray);
                    if ~any(isinf(t)) && norm(q - camera_center) - norm(t - camera_center) > epsilon
                        min_distance = min(min_distance, norm(q - p));
                        q = [inf; inf; inf];                        
                        break;
                    end
                end
            end
            n = q - s;
        end
        
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
        
        %disp([num2str(j), ': ', num2str(q')]);
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
