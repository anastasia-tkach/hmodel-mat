function [indices, projections] = compute_projections_outline(points, outline, centers, radii, camera_ray)

projections = cell(length(points), 1);
indices = cell(length(points), 1);

for i = 1:length(points)
    p = points{i};
    
    min_distance = Inf;
    for j = 1:length(outline) 
        if length(outline{j}.indices) == 1
            t1 = outline{j}.start;
            t2 = outline{j}.end;
            c = centers{outline{j}.indices};
            r = radii{outline{j}.indices};
            q = project_point_on_arc(p, c, r, camera_ray, t1, t2);
        end
        if length(outline{j}.indices) == 2
            c1 = outline{j}.start;
            c2 = outline{j}.end;
            q = project_point_on_segment(p, c1, c2);
        end
        %disp(['(', num2str(i - 1), ', ', num2str(j - 1), '):', num2str(q')]);
        if norm(p - q) < min_distance
            min_distance = norm(p - q);
            projections{i} = q;
            indices{i} = outline{j}.indices;
        end
        
    end
    
end
