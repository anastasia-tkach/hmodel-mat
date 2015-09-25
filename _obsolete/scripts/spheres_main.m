% clear;
close all;
D = 3;
while(true)
    c1 = 2 * rand(D, 1);
    c2 = 2 * rand(D, 1);
    c3 = 2 * rand(D, 1);
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

%% Generate point
while(true)
    p = rand(3, 1);
    n = cross(c1 - c2, c1 - c3);
    n = n / norm(n);
    distance = (p - c1)' * n;
    t = p - n * distance;
    if is_point_in_triangle(p, c1, c2, c3) == true
        break;
    end
end

%% Compute corrections
figure; hold on;
[sa, na, ta, delta_a] = compute_correction(c1, c2, r1, r2, t);
[sb, nb, tb, delta_b] = compute_correction(c2, c3, r2, r3, t);

u = norm(cross(sb - sa, nb)) / norm(cross(na, nb));
s = sa + u * na;


my_line(ta, sa, 'c');
my_line(tb, sb, 'c');
my_line(t, ta, 'c');
my_line(t, tb, 'c');
my_line(t, s, 'r');
my_line(p, s, 'r');
my_point(s, 'r');
% my_line(sa, sa + na, 'g');
% my_line(sb, sb + nb, 'g');

%% Compute tangent radius

normal = (p - s)/ norm(p - s);
v1 = c1 + normal * r1;
v2 = c2 + normal * r2;
v3 = c3 + normal * r3;


%% Display lines
line([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)], 'lineWidth', 2);
line([c1(1) c3(1)], [c1(2) c3(2)], [c1(3) c3(3)], 'lineWidth', 2);
line([c2(1) c3(1)], [c2(2) c3(2)], [c2(3) c3(3)], 'lineWidth', 2);
scatter3(p(1), p(2), p(3), 30, 'filled', 'm');
scatter3(t(1), t(2), t(3), 30, 'filled', 'm');
line([p(1) t(1)], [p(2) t(2)], [p(3) t(3)], 'lineWidth', 2, 'color', 'm');
axis equal;

%% Display spheres
n = 70;
centers{1} = c1;
centers{2} = c2;
centers{3} = c3;
radii{1} = r1;
radii{2} = r2;
radii{3} = r3;
num_centers = 3;
[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(num_centers, centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
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
    alpha(0.4); grid on; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
    
end

distances = zeros(N, 1);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
for i = 1:N
    p = points(i, :)';   
    distances(i) = (p - v1)' * normal;
end
distances = reshape(distances, size(x));
color = 'g';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.4); grid on; view([1,1,1]);
axis equal; camlight; lighting gouraud;

