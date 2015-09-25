function [] = draw_sphere(center, radius, color, bounding_box)
num = 60;
xm = linspace(bounding_box.min_x, bounding_box.max_x, num);
ym = linspace(bounding_box.min_y, bounding_box.max_y, num);
zm = linspace(bounding_box.min_z, bounding_box.max_z, num);
[x, y, z] = meshgrid(xm, ym, zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

distances = points - repmat(center', N, 1);
distances = distances.^2;
distances = sum(distances, 2);
distances = sqrt(distances);
distances = distances - radius;
% for i = 1:N
%     p = points(i, :)';    
%     distances(i) = norm(p - center) - radius;
% end
distances = reshape(distances, size(x));
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 0.5);
grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;