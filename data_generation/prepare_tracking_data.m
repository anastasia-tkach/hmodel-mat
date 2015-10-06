
close all; clear;
data_path = '_data/implicit_skinning/others/';
p = 7;

%% Read the data
name = [num2str(p), '.obj'];
filename = [data_path, name];

if (strcmp(name(end-2:end), 'ply'))
    [V, F] = readPLY(filename);
end
if (strcmp(name(end-2:end), 'obj'))
    [V, F] = readOBJ(filename);
end

V = [V(:, 3), V(:, 1), V(:, 2)];
N = per_vertex_normals(V, F);
mesh.normals = N;
mesh.vertices = V;
mesh.triangles = F;

%% Save the results
data_path = '_data/implicit_skinning/tracking/';

points = cell(size(mesh.vertices, 1), 1);
normals = cell(size(mesh.normals, 1), 1);
for i = 1:size(mesh.vertices, 1)
    points{i} = mesh.vertices(i, :)';
    normals{i} = mesh.normals(i, :)';
end

save([data_path, num2str(p), '_points.mat'], 'points');
save([data_path, num2str(p), '_normals.mat'], 'normals');

%% Display results
figure; hold on; axis off; axis equal;
mypoints(points, 'm');
myvectors(points, normals, 1, 'c');





