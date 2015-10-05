function [has_tangent_plane] = verify_tangent_plane(c1, c2, c3, r1, r2, r3)

if r2 > r1
    temp = r1; r1 = r2; r2 = temp;    
    temp = c1; c1 = c2; c2 = temp;
end

z = c1 + (c2 - c1) * r1 / (r1 - r2);

gamma = (c2 - c1)' * (c3 - c1) / ((c2 - c1)' * (c2 - c1));
t = c1 + gamma * (c2 - c1);

if (t - c1)' * (z - c1) > 0 && norm(t - c1) > norm(z - c1)
    t = c1 + (z - c1) + (z - t);
end

delta_r = norm(c2 - t) * (r1 - r2) / norm(c2 - c1);

if (t - c1)' * (c2 - c1) > 0 && norm(t - c1) > norm(c2 - c1)
    delta_r = -delta_r;   
end

r_tilde = delta_r + r2;

beta = asin((r1 - r2) / norm(c2 - c1));
r = r_tilde/cos(beta);

eta = r3 + norm(c3 - t);

if (eta < r)
    has_tangent_plane = false;
else
    has_tangent_plane = true;
end

return

%% Draw lines
figure('units','normalized','outerposition',[0 0 1 1]); hold on; 
myline(c1, c2, 'b'); mypoint(c1, 'b'); mypoint(c2, 'b');
myline(c3, t, 'r'); mypoint(c3, 'r');

%% Draw spheres
n = 60;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xm = linspace(min_x, max_x, n); ym = linspace(min_y, max_y, n); zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

centers{1} = c1; centers{2} = c2; centers{3} = c3;
radii{1} = r1; radii{2} = r2; radii{3} = r3;

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
distances = distance_to_model_convsegment(c1, c2, r1, r2, points');
distances = reshape(distances, size(x));
color = 'c';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.3); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud; axis off;