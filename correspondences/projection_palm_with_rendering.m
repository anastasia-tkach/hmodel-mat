function [indices, projections, axis_projections, is_best_projection]  = projection_palm_with_rendering(centers, radii, blocks, data_points, camera_ray, camera_center, blocks_matrix, bounding_box, settings)

C = 50;

%% List the primitives
[blocks, tangent_points, unique_indices] = prepare_triangles_and_convsegments(centers, blocks, radii, camera_ray);

%{
%% ADJUST TRIANGLES
figure; hold on; axis off; axis equal;
for i = 1:length(blocks)
    if length(blocks{i}) < 3, continue; end
    v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
    myline(v1, v2, 'b'); myline(v2, v3, 'b'); myline(v1, v3, 'b');
    draw_triangle(v1, v2, v3, 'c');
    
    for j = i + 1:length(blocks)
        if length(blocks{j}) < 3, continue; end
        if sum(ismember(abs(blocks{i}), abs(blocks{j}))) < 2, continue; end
        
        u1 = tangent_points{j}.v1; u2 = tangent_points{j}.v2; u3 = tangent_points{j}.v3;

        [i1, i2] = intersect_trinagle_triangle(v1, v2, v3, u1, u2, u3);
        
        if any(isinf(i1)) || any(isinf(i2)), continue; end
        
        %myline(i1, i2, 'm');
        
        t = intersect_segment_segment_same_plane(v1, v2, i1, i2);
        if all(~isinf(t))
            if norm(v1 - t) < norm(v2 - t), tangent_points{i}.v1 = t;
            else tangent_points{i}.v2 = t; end
        end
        t = intersect_segment_segment_same_plane(v1, v3, i1, i2);
        if all(~isinf(t))
            if norm(v1 - t) < norm(v3 - t), tangent_points{i}.v1 = t;
            else tangent_points{i}.v3 = t; end
        end
        t = intersect_segment_segment_same_plane(v2, v3, i1, i2);
        if all(~isinf(t))
            if norm(v3 - t) < norm(v2 - t), tangent_points{i}.v3 = t;
            else tangent_points{i}.v2 = t; end
        end
        
        t = intersect_segment_segment_same_plane(u1, u2, i1, i2);
        if all(~isinf(t))
            if norm(u1 - t) < norm(u2 - t), tangent_points{j}.v1 = t;
            else tangent_points{j}.v2 = t; end
        end
        t = intersect_segment_segment_same_plane(u1, u3, i1, i2);
        if all(~isinf(t))
            if norm(u1 - t) < norm(u3 - t), tangent_points{j}.v1 = t;
            else tangent_points{j}.v3 = t; end
        end
        t = intersect_segment_segment_same_plane(u2, u3, i1, i2);
        if all(~isinf(t))
            if norm(u3 - t) < norm(u2 - t), tangent_points{j}.v3 = t;
            else tangent_points{j}.v2 = t; end
        end
        
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
    end
end

figure; hold on; axis off; axis equal;
for i = 1:length(blocks)
    if length(blocks{i}) < 3, continue; end
    v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
    myline(v1, v2, 'b'); myline(v2, v3, 'b'); myline(v1, v3, 'b');
end
%}

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
        %disp(blocks{j});
        
        if length(blocks{j}) == 3
            v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
            n = tangent_points{j}.n;
            distance = (p - v1)' * n;
            q = p - n * distance;
            if (is_point_in_triangle(q, v1, v2, v3));
                index = blocks{j};               
            else
                continue;
            end
        end
        
        if length(blocks{j}) == 2
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            index1 = blocks{j}(1); index2 = blocks{j}(2);
            [index, q, s, ~] = projection_convsegment(p, c1, c2, r1, r2, index1, index2);
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
        
        %disp([num2str(j), ': ', num2str(q')]);
        %mypoint(q, 'b'); drawnow;
        %disp(block_from_hash(w));
        
        %% Find z coordinate of whatever is infront
        if all(W ~= current_w)
            if blocks_matrix(round(y), round(x)) == -RAND_MAX
                q = [inf; inf; inf]; continue; 
            end
            
            front_block = block_from_hash(blocks_matrix(round(y), round(x)));
            o = camera_center; o(1) = q(1); o(2) = q(2);
            
            if length(front_block) == 3
                b = -1;
                for k = 1:length(blocks) % precompute w->index map instead
                    if all(ismember(front_block, blocks{k})),
                        b = k; break;
                    end
                end
                v1 = tangent_points{b}.v1; v2 = tangent_points{b}.v2; v3 = tangent_points{b}.v3;                
                [q, ~]  = ray_triangle_intersection (v1, v2, v3, o, camera_ray);
            end
            if length(front_block) == 2
                c1 = centers{front_block(1)}; c2 = centers{front_block(2)};
                r1 = radii{front_block(1)}; r2 = radii{front_block(2)};                
                [q, ~, ~] = ray_convsegment_intersection(c1, c2, r1, r2, 0, 0, o, camera_ray);
            end              
        end
        
        %% Compute distance
        distance = norm(p - q);       
        
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
