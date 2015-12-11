function [] = display_convsegments_in_convtriangles(pose, blocks, radii)

centers = pose.centers;
n = 60;

[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

for i = 1:length(blocks)
    if length(blocks{i}) == 3
        c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)}; c3 = pose.centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        
        if (i == 1)
            distances = compute_distances_to_model(c1, c2, r1, r2, points');
            display_isosurface(x, y, z, distances, i, 1);
            distances = compute_distances_to_model(c1, c3, r1, r3, points');
            display_isosurface(x, y, z, distances, i, 1);
            distances = compute_distances_to_model(c2, c3, r2, r3, points');
            display_isosurface(x, y, z, distances, i, 1);
        end
        if (i == 2)
            distances = compute_distances_to_model(c1, c2, r1, r2, points');
            display_isosurface(x, y, z, distances, i, 0.5);
            distances = compute_distances_to_model(c1, c3, r1, r3, points');
            display_isosurface(x, y, z, distances, i, 0.5);
            distances = compute_distances_to_model(c2, c3, r2, r3, points');
            display_isosurface(x, y, z, distances, i, 0);
        end
    end
    
end

end
function display_isosurface(x, y, z, distances, i, alpha)

distances = reshape(distances, size(x));
if i == 1, color = 'r'; end;
if i == 2, color = 'y'; end;
if i == 3, color = 'b'; end;

h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', alpha);
grid off; view([1,1,1]); axis equal; camlight; lighting gouraud;

end
