filename = 'C:\Users\tkach\OneDrive\EPFL\Code\HandModel\data\full_models\bunny.ply';

% [vertex,face] = read_mesh(filename);
% V = vertex';
% F = face';
[V,F] = readPLY(filename);

figure; hold on;
plot_mesh(V', F');

bb = bounding_box(V);

%n = 20;
% min_x = min(bb(:, 1)); max_x = max(bb(:, 1));
% min_y = min(bb(:, 2)); max_y = max(bb(:, 2));
% min_z = min(bb(:, 3)); max_z = max(bb(:, 3));
% xm = linspace(min_x, max_x, n);
% ym = linspace(min_y, max_y, n);
% zm = linspace(min_z, max_z, n);
% [x, y, z] = meshgrid(xm, ym, zm); N = numel(x);
% P = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
% [S,I,C,N] = signed_distance(P, V, F);
% 
% distances = reshape(distances, size(x));
% 
% %% Making the 3D graph of the 0-level surface of the 4D function "fun":
% color = [0, 0.5, 0.5];
% h = patch(isosurface(x, y, z, distances,0));
% isonormals(x, y, z, distances, h);
% set(h,'FaceColor',color,'EdgeColor','none');
% 
% %% Aditional graphic details:
% alpha(0.7); grid off; view([1,1,1]);
% axis equal; camlight; lighting gouraud;