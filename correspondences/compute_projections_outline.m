function [indices, projections, block_indices, axis_points] = compute_projections_outline(points, outline, centers, radii, camera_ray)

projections = cell(length(points), 1);
indices = cell(length(points), 1);
block_indices = cell(length(points), 1);
axis_points = cell(length(points), 1);

for i = 1:length(points)
    p = points{i};
    
    min_distance = Inf;
    for j = 1:length(outline) 
        if length(outline{j}.indices) == 1
            t1 = outline{j}.start;
            t2 = outline{j}.end;
            c = centers{outline{j}.indices(1)};
            r = radii{outline{j}.indices(1)};
            q = project_point_on_arc(p, c, r, camera_ray, t1, t2);
            s = centers{outline{j}.indices(1)};
        end
        if length(outline{j}.indices) == 2
            t1 = outline{j}.start;
            t2 = outline{j}.end;
            q = project_point_on_segment(p, t1, t2);
            c1 = centers{outline{j}.indices(1)};
            c2 = centers{outline{j}.indices(2)};
            r1 = radii{outline{j}.indices(1)};
            r2 = radii{outline{j}.indices(2)};
            if (r2 > r1)
                temp = c1; c1 = c2; c2 = temp;
                temp = r1; r1 = r2; r2 = temp;
            end
            [t, s, ~] = project_skewed_point_on_segment(q, c1, c2, r1, r2, outline{j}.indices(1), outline{j}.indices(2));
            if norm(t - q) > 1e-4
                disp(' ');
            end
        end
        %disp(['(', num2str(i - 1), ', ', num2str(j - 1), '):', num2str(q')]);
        if norm(p - q) < min_distance
            min_distance = norm(p - q);
            projections{i} = q;
            indices{i} = outline{j}.indices;
            block_indices{i} = outline{j}.block;
            axis_points{i} = s;
        end
        
    end
    
end
