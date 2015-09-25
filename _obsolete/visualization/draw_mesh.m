function [] = draw_mesh(mesh, view_vector, color, mode)

Vertices = mesh.vertices;
Triangles = mesh.triangles;

hold on; axis equal;
for i = 1:size(Triangles)
    k = i;
    X = [Vertices(Triangles(k, :), 1); Vertices(Triangles(k, 1), 1)];
    Y = [Vertices(Triangles(k, :), 2); Vertices(Triangles(k, 1), 2)];
    Z = [Vertices(Triangles(k, :), 3); Vertices(Triangles(k, 1), 3)];

    if (view_vector(1) == 1)
        if strcmp(mode, 'filled') == 1
            fill3(X, Z, Y, [209/255, 180/255, 189/255], 'edgeColor', 'none', 'lineWidth', 2)
        else
            line(X, Z, Y, 'color', [196/255, 178/255, 190/255], 'lineWidth', 2, 'color', color);
        end

    end
    if (view_vector(3) == 1)
        if strcmp(mode, 'filled') == 1
            fill3(X, Y, Z, [209/255, 180/255, 189/255], 'edgeColor', 'none', 'lineWidth', 2)
        else
            line(X, Y, Z, 'color', [196/255, 178/255, 190/255], 'lineWidth', 2, 'color', color);
        end
    end
    %line(X, Y, Z, 'color', [181/255, 123/255, 154/255], 'lineWidth', 2);    
    %fill3(X, Y, Z, [209/255, 180/255, 189/255], 'edgeColor', [196/255, 153/255, 177/255], 'lineWidth', 2)
   
end

view(view_vector);
axis off;