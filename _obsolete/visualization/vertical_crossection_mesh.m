function [] = vertical_crossection(mesh, p0)

n = [1; 0; 0];

k = 1;
for i = 1:size(mesh.triangles, 1)
    p1 = mesh.vertices(mesh.triangles(i, 1), :);
    p2 = mesh.vertices(mesh.triangles(i, 2), :);
    p3 = mesh.vertices(mesh.triangles(i, 3), :);
    [is_intersect, intersection] = intersect_plane_triangle(n, p0, p1, p2, p3);
    if is_intersect
        intersections{k} = intersection;
        k = k + 1;
    end
end

u = [0; 1; 0];
v = [0; 0; 1];
B = [u, v, n];
figure;
for i = 1:length(intersections)
    p1 = intersections{i}(:, 1);
    alpha = B \ p1;
    p2 = intersections{i}(:, 2);
    beta = B \ p2;
    line([alpha(2), beta(2)], [alpha(1), beta(1)], 'lineWidth', 2, 'color',  [196/255, 153/255, 177/255]);
end
axis equal; axis off;

