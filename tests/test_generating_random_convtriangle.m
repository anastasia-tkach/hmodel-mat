clear;
close all;
D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
    x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x); [r3, i3] = min(x);
    x([i1, i3]) = 0; r2 = max(x);
    if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
        break;
    end
end
% clear;
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\c1.mat');
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\c2.mat');
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\c3.mat');
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\r1.mat');
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\r2.mat');
% load('C:\Users\Anastasia\Desktop\HandModel_24.07\failure_case\r3.mat');

%% Find the tangent plane
z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
z13 = c1 + (c3 - c1) * r1 / (r1 - r3);

l = (z12 - z13) / norm(z12 - z13);
projection = (c1 - z12)' * l;
z = z12 + projection * l;

beta = asin(r1/norm(c1 - z));

g = rotate_around_axis(l, c1 - z, beta);
v1 = z + norm(c1 - z) * cos(beta) * g;
n = v1  - c1; n = n / norm(n);
v2 = c2 + r2 * n;
v3 = c3 + r3 * n;

g = rotate_around_axis(l, c1 - z, -beta);
u1 = z + norm(c1 - z) * cos(beta) * g;
m = c1 - u1; m = m / norm(m);
u2 = c2 - r2 * m;
u3 = c3 - r3 * m;

%% Display
num = 50;
centers{1} = c1; centers{2} = c2; centers{3} = c3;
radii{1} = r1; radii{2} = r2; radii{3} = r3;
num_centers = 3;
bounding_box = compute_model_bounding_box(centers, radii);
min_x = bounding_box.min_x;
min_y = bounding_box.min_y;
min_z = bounding_box.min_z;
max_x = bounding_box.max_x;
max_y = bounding_box.max_y;
max_z = bounding_box.max_z;

xm = linspace(min_x, max_x, num);
ym = linspace(min_y, max_y, num);
zm = linspace(min_z, max_z, num);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
figure; hold on;
myline(c1, c2, [0, 0.4, 0.9]); myline(c1, c3, [0, 0.4, 0.9]); myline(c2, c3, [0, 0.4, 0.9]);
myline(c1, v1, [0.2, 0.7, 1.0]); myline(c2, v2, [0.2, 0.7, 1.0]); myline(c3, v3, [0.2, 0.7, 1.0]);
myline(c1, u1, [0.2, 0.7, 1.0]); myline(c2, u2, [0.2, 0.7, 1.0]); myline(c3, u3, [0.2, 0.7, 1.0]);

%% Mex file
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances_mex = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, points');
distances_mex = reshape(distances_mex, size(x));

distances_mex = reshape(distances_mex, size(x));
color = 'c';
h = patch(isosurface(x, y, z, distances_mex,0));
isonormals(x, y, z, distances_mex, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.4); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;


%% Draw spheres
figure; hold on;
for j = 1:length(centers)
    
    distances = zeros(N, 1);
    points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
    for i = 1:N
        p = points(i, :)';        
        distances(i) = norm(p - centers{j}) - radii{j};
    end
    
    distances = reshape(distances, size(x));
    color = 'c';
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none');
    alpha(0.4); grid off; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
    
end

return;

%% Matlab function
distances = zeros(N, 1);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
index1 = 1; index2  = 2; index3 = 3;
for i = 1:N
    p = points(i, :)';
    [~, q, s, ~] = projection_convtriangle(p, c1, c2, c3, r1, r2, r3, index1, index2, index3);
    if norm(p - s) >= norm(q - s)
        distances(i) = norm(p - q);
    else
        distances(i) = - norm(p - q);
    end
end

figure; hold on;
distances = reshape(distances, size(x));
color = 'c';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.4); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;


%% Find differences

distances = reshape(distances, N, 1);
distances_mex = reshape(distances_mex, N, 1);
wrong_indices = [];
for i = 1:N
    if abs(distances(i) - distances_mex(i)) > 10e-2
        wrong_indices = [wrong_indices; i];
    end
end

[distances(wrong_indices) distances_mex(wrong_indices)];
wrong_points = points(wrong_indices, :);



