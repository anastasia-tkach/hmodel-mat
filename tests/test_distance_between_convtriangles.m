clear;
D = 3;
close all;
[centers1, radii1, blocks1] = get_random_convtriangle();
[centers2, radii2, blocks2] = get_random_convtriangle();
for i = 1:length(radii1)
    radii1{i} = radii1{i} * 0.5;
    radii2{i} = radii2{i} * 0.5;
end
centers = [centers1; centers2]; radii = [radii1; radii2];
a = rand; b = rand; c = 1 - a - b;
[a, b, c]

centers1 = centers(1:3); centers2 = centers(4:6);
radii1 = radii(1:3); radii2 = radii(4:6);

c1 = centers1{1}; c2 = centers1{2}; c3 = centers1{3};
c4 = centers2{1}; c5 = centers2{2}; c6 = centers2{3};
r1 = radii1{1}; r2 = radii1{2}; r3 = radii1{3};
r4 = radii2{1}; r5 = radii2{2}; r6 = radii2{3};

figure; hold on;
display_result_convtriangles(centers1, [], [], blocks1, radii1, true);


point = a * c1 + b * c2 + c * c3;
[v1, v2, v3, u1, u2, u3] = tangent_points_function(c1, c2, c3, r1, r2, r3); normal = (c1 - v1)/norm(c1 - v1);
radius = get_convolution_radius_at_points(centers, radii, [1, 2, 3], normal, point);
radius = radius + radius * 0.01;
mypoint(point, 'k');
myline(c1, c2, 'm'); myline(c2, c3, 'm'); myline(c1, c3, 'm');

num = 80;
bounding_box = compute_model_bounding_box(centers, radii);
min_x = bounding_box.min_x; min_y = bounding_box.min_y; min_z = bounding_box.min_z;
max_x = bounding_box.max_x; max_y = bounding_box.max_y; max_z = bounding_box.max_z;
xm = linspace(min_x, max_x, num); ym = linspace(min_y, max_y, num); zm = linspace(min_z, max_z, num);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
distances = zeros(N, 1);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
for i = 1:N
    p = points(i, :)';
    distances(i) = norm(p - point) - radius;
end
distances = reshape(distances, size(x));
color = 'k';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha' , 1);
grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;























