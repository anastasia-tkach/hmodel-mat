function [has_tangent_cone] = verify_tangent_cone(c1, c2, r1, r2)

if r2 > r1
    temp = r1; r1 = r2; r2 = temp;    
    temp = c1; c1 = c2; c2 = temp;
end

if norm(c2 - c1) + r2 < r1
    has_tangent_cone = false;
else
    has_tangent_cone = true;
end

return

%% Draw lines
figure('units','normalized','outerposition',[0 0 1 1]); hold on; 
myline(c1, c2, 'b'); mypoint(c1, 'b'); mypoint(c2, 'b');


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

alpha(0.3); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;

