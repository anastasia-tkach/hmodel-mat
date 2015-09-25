%% Initialize

close all; clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'points']);
load([path, 'centers']);

[blocks] = reindex(radii, blocks);
block = blocks{1};

%%  Compute 
c1 = centers{block(1)}; c2 = centers{block(2)}; c3 = centers{block(3)};
r1 = radii{block(1)}; r2 = radii{block(2)}; r3 = radii{block(3)};

z = c1 + (c2 - c1) * r1 / (r1 - r2);

gamma = (c2 - c1)' * (c3 - c1) / ((c2 - c1)' * (c2 - c1));
t = c1 + gamma * (c2 - c1);

if (t - c1)' * (z - c1) > 0 && norm(t - c1) > norm(z - c1)
    t = c1 + (z - c1) + (z - t);
end

delta_r = norm(c2 - t) * (r1 - r2) / norm(c2 - c1);

if (t - c1)' * (c2 - c1) > 0 && norm(t - c1) > norm(c2 - c1)
    delta_r = -delta_r;
    disp('changed sign');
end

r_tilde = delta_r + r2;

beta = asin((r1 - r2) / norm(c2 - c1));
r = r_tilde/cos(beta);

eta = r3 + norm(c3 - t);

if (eta < r)
    disp('no  tangent plane');
else
    disp('its ok');
end

%% Draw lines
figure('units','normalized','outerposition',[0 0 1 1]); hold on; 
myline(c1, c2, 'b'); mypoint(c1, 'b'); mypoint(c2, 'b');
%myline(c1, z, 'b'); mypoint(z, 'b');
myline(c3, t, 'r'); mypoint(c3, 'r');

%% Draw spheres
n = 60;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xm = linspace(min_x, max_x, n); ym = linspace(min_y, max_y, n); zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

for j = 1:length(centers)
    distances = zeros(N, 1);
    for i = 1:N
        p = points(i, :)';
        distances(i) = norm(p - centers{j}) - radii{j};
    end
    distances = reshape(distances, size(x));
    color = 'c';
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none');
end

%% Draw convsegment
distances = compute_distances_to_model(c1, c2, r1, r2, points');
distances = reshape(distances, size(x));
color = 'c';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.3); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;

