function [mesh] = generate_sphere_mesh(c, r)

u = 10;
v = 6;

vertices = zeros(3, u, v);

for i = 1:u
    for j = 1:v
        theta = i * 2 * pi/u;
        phi = j * pi/v;
        x = r * cos(theta) * sin(phi);
        y = r * sin(theta) * sin(phi);
        z = r * cos(phi);
        vertices(1, i, j) = x;
        vertices(2, i, j) = y;
        vertices(3, i, j) = z;
    end
end

vertices = reshape(vertices, 3, u * v)';
vertices = vertices(1:end - u, :);
vertices = [[0, 0, r]; vertices];
vertices = [vertices; [0, 0, -r]];

%% Create the triangles for the top vertex
triangles = [];
indices = [1:u, 1];
for j = 1:u
    t1 = [1, indices(j), indices(j + 1)];
    t2 = [1, indices(j), indices(j + 1)];
    triangles = [triangles; t1; t2];
end

%% Create the triagnles for regular vertices
indices = 1:u * (v - 1);
indices = indices + 1;
indices = reshape(indices, u, (v - 1))';
indices = [indices, indices(:, 1)];

for i = 1:v - 2
    for j = 1:u
        t1 = [indices(i, j), indices(i + 1, j), indices(i, j + 1)];
        t2 = [indices(i + 1, j + 1), indices(i + 1, j), indices(i, j + 1)];
        triangles = [triangles; t1; t2];
    end
end

%% Create the triangles for the bottom vertex
num_vertices = size(vertices, 1);
indices = [num_vertices - u + 1:num_vertices, num_vertices - u + 1];

for j = 1:u
    t1 = [num_vertices, indices(j), indices(j + 1)];
    t2 = [num_vertices, indices(j), indices(j + 1)];
    triangles = [triangles; t1; t2];
end

vertices = repmat(c, size(vertices, 1), 1) + vertices;
mesh.vertices = vertices;
mesh.triangles = triangles;




