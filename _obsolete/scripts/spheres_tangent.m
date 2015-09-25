%clear;
close all;
D = 3;
while(true)
    c1 = 0.5 * rand(D, 1);
    c2 = 0.5 * rand(D, 1);
    c3 = 0.5 * rand(D, 1);
    x1 = rand(1, 1);
    x2 = rand(1, 1);
    x3 = rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x);
    [r3, i3] = min(x);
    x([i1, i3]) = 0;
    r2 = max(x);
    if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
        break;
    end
end

%% Find the tangent plane
z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
z13 = c1 + (c3 - c1) * r1 / (r1 - r3);

l = (z12 - z13) / norm(z12 - z13);
projection = (c1 - z12)' * l;
z = z12 + projection * l;

beta = asin(r1/norm(c1 - z));

g = rotate_around_axis(l, c1 - z, beta);
v1 = z + norm(c1 - z) * cos(beta) * g;
n = v1  - c1;
n = n / norm(n);
v2 = c2 + r2 * n;
v3 = c3 + r3 * n;

g = rotate_around_axis(l, c1 - z, -beta);
u1 = z + norm(c1 - z) * cos(beta) * g;
m = c1 - u1;
m = m / norm(m);
u2 = c2 + r2 * m;
u3 = c3 + r3 * m;

%% Draw lines

% mypoint(v1, 'k');
% mypoint(v2, 'k');
% mypoint(v3, 'k');
% 
% myline(v1, c1, 'k');
% myline(v2, c2, 'k');
% myline(v3, c3, 'k');
% 
% myline(v1, v2, 'k');
% myline(v2, v3, 'k');
% myline(v1, v3, 'k');
% 
% myline(c1, c2, 'm');
% myline(c2, c3, 'm');
% myline(c1, c3, 'm');


%% Display
num = 50;
centers{1} = c1;
centers{2} = c2;
centers{3} = c3;
radii{1} = r1;
radii{2} = r2;
radii{3} = r3;
num_centers = 3;
[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(num_centers, centers, radii);
xm = linspace(min_x, max_x, num);
ym = linspace(min_y, max_y, num);
zm = linspace(min_z, max_z, num);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);


for c = 1:num_centers
    distances = zeros(N, 1);
    points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
    for i = 1:N
        p = points(i, :)';
        distances(i) = norm(p - centers{c}) - radii{c};
    end
    distances = reshape(distances, size(x));
    
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    color = 'c';
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none');
    alpha(0.7); grid off; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
    
end

%% Draw tangent planes
normals{1} = n;
normals{2} = m;
origins{1} = v1;
origins{2} = u1;
for k = 1:2
    distances = zeros(N, 1);
    points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
    for i = 1:N
        p = points(i, :)';
        distances(i) = (p - origins{k})' * normals{k};
    end
    distances = reshape(distances, size(x));
    color = 'g';
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none');
    alpha(0.4); grid off; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
end
