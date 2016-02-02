function [indices, projections]  = projection_palm_skeleton(centers, radii, blocks, data_points, camera_ray)
%% List the primitives
[blocks, tangent_points, unique_indices] = prepare_triangles_and_convsegments(centers, blocks, radii, camera_ray);

%% COMPUTE PROJECTION
num_points = length(data_points);

indices = cell(num_points, 1);
projections = cell(num_points, 1);
normals = cell(num_points, 1);

for i = 1:num_points
    
    p = data_points{i};
    min_distance = inf;
    
    %shadowed_segments = {};
    
    %% Distance to triangles
    for u = 1:length(unique_indices)
        j = unique_indices(u);
        if length(blocks{j}) == 2, continue; end
        
        v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
        n = tangent_points{j}.n;
        distance = (p - v1)' * n;
        q = p - n * distance;
        %mypoint(q, 'k');
        if ~is_point_in_triangle(q, v1, v2, v3), continue; end
        
        %shadowed_segments{end + 1} = [blocks{j}(1), blocks{j}(2)];
        %shadowed_segments{end + 1} = [blocks{j}(2), blocks{j}(3)];
        %shadowed_segments{end + 1} = [blocks{j}(1), blocks{j}(3)];
        
        distance = norm(p - q);
        if distance < min_distance
            min_distance = distance;
            indices{i} = blocks{j};
            projections{i} = q;
            normals{i} = n;
        end
    end
    
    %% Distance to segments
    shadowed_spheres = {};
    
    if isinf(min_distance)
        for u = 1:length(unique_indices)
            j = unique_indices(u);
            if length(blocks{j}) == 3, continue; end
            %for k = 1:length(shadowed_segments), if ismember(blocks{j}, shadowed_segments{k}), continue; end; end;            
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            
            x = c2 - c1;
            alpha = x' * (p - c1) / (x' * x);
            t = c1 + alpha * x;
            omega = sqrt(x' * x - (r1 - r2)^2);
            delta =  norm(p - t) * (r1 - r2) / omega;
            s = t - delta * x / norm(x);
            
            if ~is_point_on_segment(c1, c2, s), continue; end
            shadowed_spheres{end + 1} = blocks{j}(1);
            shadowed_spheres{end + 1} = blocks{j}(2);
            
            gamma = (r1 - r2) * norm(c2 - t + delta * x / norm(x))/ sqrt(x' * x);
            q = s + (p - s) / norm(p - s) * (gamma + r2);            
           
            mypoint(q, 'g');
            myline(c1, c2, 'g');
            
            n = q - s;
            
            distance = norm(p - q);
            if distance < min_distance
                min_distance = distance;
                indices{i} = blocks{j};
                projections{i} = q;
                normals{i} = n;
            end
        end
                
        
        %% Distance to spheres
        
        for j = 1:length(centers)
            is_present = false;
            for k = 1:length(blocks), if ismember(j, blocks{k}), is_present = true; break; end; end
            if ~is_present, continue; end
            for k = 1:length(shadowed_spheres)
                if j == shadowed_spheres{k}, continue; end
            end
            
            c1 = centers{j}; r1 = radii{j};
            q = c1 + r1 * (p - c1) / norm(p - c1);
            
            mypoint(q, 'r');
            
            n = q - c1;
            
            distance = norm(p - q);
            if distance < min_distance
                min_distance = distance;
                indices{i} = j;
                projections{i} = q;
                normals{i} = n;
            end
        end
    end
    
    if camera_ray' * normals{i} > 0,
        projections{i} = [inf; inf; inf];
    end
end
