function [indices, projections, block_indices] = compute_tracking_projections(points, centers, blocks, radii, camera_center)

num_points = length(points);

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
min_distance = Inf * ones(num_points, 1);
projections = cell(num_points, 1);
axis_projections = cell(num_points, 1);
insidness = zeros(num_points);

tangent_points = blocks_tangent_points(centers, blocks, radii);

for i = 1:num_points
    p = points{i};
    for j = 1:length(blocks)
        [index, q, s, is_inside] = projection(p, blocks{j}, radii, centers, tangent_points{j});
        if norm(p - q) < min_distance(i)
            min_distance(i) = norm(p - q);
            projections{i} = q;
            insidness(i) = is_inside;
            block_indices{i} = j;
            indices{i} = index;
        end
    end
    min_distance(i) = Inf;
    for j = 1:length(blocks)
        p = points{i};
        block = blocks{j};
        
        if ~insidness(i)
            p = projections{i};
        end
            
            
            if (length(block) == 3)
                c1 = centers{block(1)}; c2 = centers{block(2)}; c3 = centers{block(3)};
                r1 = radii{block(1)}; r2 = radii{block(2)}; r3 = radii{block(3)};
                v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
                u1 = tangent_points{j}.u1; u2 = tangent_points{j}.u2; u3 = tangent_points{j}.u3;
                intersection = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, camera_center, (p - camera_center) / norm(p - camera_center));
            end
            if length(block) == 2
                c1 = centers{block(1)}; c2 = centers{block(2)};
                r1 = radii{block(1)}; r2 = radii{block(2)};
                intersection = ray_convsegment_intersection(c1, c2, r1, r2, camera_center, (p - camera_center) / norm(p - camera_center));
            end
            if norm(intersection - camera_center) < min_distance(i)
                min_distance(i) = norm(intersection - camera_center);
                indices{i} = index;
                projections{i} = intersection;
                block_indices{i} = j;
            end
            
        %else
             %projections{i} = [];
        %end
        
    end
end