%mesh = cylinders_model();
close all;
mesh.vertices = V;
mesh.triangles = F;

figure; axis equal; hold on;
%draw_projected_mesh(mesh, 'XY');
scatter(mesh.vertices(:, 1), mesh.vertices(:, 2), 1, [1, 0.5, 0], 'filled')

%% Define a plane
U = zeros(2, 2);
for i = 1:2
    [x, y] = ginput(1);
    scatter(x, y, 20, 'm', 'filled');
    U(1, i) = x;
    U(2, i) = y;
end
line(U(1, :), U(2, :), 'color', [0.5, 0.1 0.7], 'lineWidth', 3);
u = U(:, 2) - U(:, 1);
u = [u; 0];
u = u / norm(u);
v = [0; 0; 1];
w = cross(u, v);

k = 1;
intersections = [];
for i = 1:size(mesh.triangles, 1)
    p1 = mesh.vertices(mesh.triangles(i, 1), :);
    p2 = mesh.vertices(mesh.triangles(i, 2), :);
    p3 = mesh.vertices(mesh.triangles(i, 3), :);
    [is_intersect, intersection] = intersect_plane_triangle(w, [x, y, 0], p1, p2, p3);
    if is_intersect
        intersections{k} = intersection;
        k = k + 1;
    end
end

B = [u, v, w];
figure; hold on;
for i = 1:length(intersections)
    p1 = intersections{i}(:, 1);
    alpha = B \ p1;
    p2 = intersections{i}(:, 2);
    beta = B \ p2;
    line([alpha(2), beta(2)], [alpha(1), beta(1)], 'lineWidth', 2, 'color',  [196/255, 153/255, 177/255]);
    %line([p1(1), p2(1)], [p1(2), p2(2)], [p1(3), p2(3)], 'lineWidth', 2, 'color',  [196/255, 153/255, 177/255]);
end
axis equal; axis off;

