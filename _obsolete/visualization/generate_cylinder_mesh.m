function [mesh] = generate_cylinder_mesh(r1, r2, c1, c2)

u = 7;
v = 10;
d = norm(c2 - c1);

vertices = [];
for i = 0:v
    z = i * d / v;
    r = ((d - z) * r1 + z * r2) / d;
    c = c1 + z * (c2 - c1) / norm(c2 - c1);
    circle = circle_in_plane(c, (c2 - c1) / norm(c2 - c1), r, u);
    vertices = [vertices; circle];
end

%% Create the triagnles for regular vertices
indices = 1:u * (v + 1);
indices = reshape(indices, u, v + 1)';
indices = [indices, indices(:, 1)];
triangles = [];
for i = 1:v
    for j = 1:u
        t1 = [indices(i, j), indices(i + 1, j), indices(i, j + 1)];
        t2 = [indices(i + 1, j + 1), indices(i + 1, j), indices(i, j + 1)];
        triangles = [triangles; t1; t2];
    end
end

mesh.vertices = vertices;
mesh.triangles = triangles;


