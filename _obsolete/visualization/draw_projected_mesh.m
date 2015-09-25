function [] = draw_projected_mesh(mesh, plane)

Vertices = mesh.vertices;
Triangles = mesh.triangles;

%figure; hold on; axis equal;
for i = 1:size(Triangles)
    k = i;
    X = [Vertices(Triangles(k, :), 1); Vertices(Triangles(k, 1), 1)];
    Y = [Vertices(Triangles(k, :), 2); Vertices(Triangles(k, 1), 2)];
    Z = [Vertices(Triangles(k, :), 3); Vertices(Triangles(k, 1), 3)];
    
    switch plane
        case 'XY'
            line(X, Y, 'color', [196/255, 178/255, 190/255], 'lineWidth', 3);
        case 'XZ'
            line(X, Z, 'color', [196/255, 178/255, 190/255], 'lineWidth', 3);
        case 'YZ'
            line(Y, Z, 'color', [196/255, 178/255, 190/255], 'lineWidth', 3);
    end

    %fill(X, Y, [209/255, 180/255, 189/255], 'edgeColor', [196/255, 153/255, 177/255], 'lineWidth', 2)
    %fill(X, Y, [209/255, 180/255, 189/255], 'edgeColor', 'none', 'lineWidth', 2)
end

%view([-1, 0, 0]);
%view([0, 0, 1]);
axis off;