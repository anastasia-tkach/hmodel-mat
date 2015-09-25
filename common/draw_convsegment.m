function [] = draw_convsegment(block, centers, radii, color)

n = 60;

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
c1 = centers{block(1)}; c2 = centers{block(2)};
r1 = radii{block(1)}; r2 = radii{block(2)};
distances = compute_distances_to_model(c1, c2, r1, r2, points');
distances = reshape(distances, size(x));

h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 0.5);

grid off; view([1,1,1]);
axis equal; camlight;
lighting gouraud;

