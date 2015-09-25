function [mesh] = remove_interior_vertices(mesh, c1, c2, r1, r2)
vertices = mesh.vertices;
triangles = mesh.triangles;

num_vertices = size(vertices, 1);
num_triangles = size(triangles, 1);

%% Find vertices inside of cylinder
indicator_vertices = ones(num_vertices, 1);
for i = 1:num_vertices    
    p = vertices(i, :)';
    %if norm(p - c1) > r1 && norm(p - c2) > r2, continue; end;
    projection = (c2 - c1)' * (p - c1) / ((c2 - c1)' * (c2 - c1));
    if projection > 0
        indicator_vertices(i) = 0;
    end
end

%% Shift vertices in triangles on the boarder
indicator_triangles = ones(num_triangles, 3);
remove_indices = [];
for i = 1:num_triangles
    for j = 1:3
        indicator_triangles(i, j) = indicator_vertices(triangles(i, j));
    end
    if sum(indicator_triangles(i, :)) == 0
        remove_indices = [remove_indices, i];
        continue;
    end;
    if sum(indicator_triangles(i, :)) == 1
        j1 = find(indicator_triangles(i, :) == 1);
        j2 = find(indicator_triangles(i, :) == 0, 1, 'first');
        j3 = find(indicator_triangles(i, :) == 0, 1, 'last');
        v1 = vertices(triangles(i, j1), :)';
        v2 = vertices(triangles(i, j2), :)';
        v3 = vertices(triangles(i, j3), :)';
        
        vertices(triangles(i, j2), :) = get_intersection(v1, v2, c1, c2);
        vertices(triangles(i, j3), :) = get_intersection(v1, v3, c1, c2);
        
    end
    if sum(indicator_triangles(i, :)) == 3, continue; end;
end

triangles(remove_indices, :) = [];

mesh.triangles = triangles;
mesh.vertices = vertices;

end

function [t]  = get_intersection(v1, v2, c1, c2)
for k = 1:5
    t = (v1 + v2)/2;
    projection = (c2 - c1)' * (t - c1) / ((c2 - c1)' * (c2 - c1));
    if projection <= 0
        v1 = t;
    else
        v2 = t;
    end
end
end