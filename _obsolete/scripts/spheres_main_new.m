% clear;
close all;
D = 3;
% while(true)
%     v1 = 2 * rand(D, 1);
%     v2 = 2 * rand(D, 1);
%     v3 = 2 * rand(D, 1);
%     x1 = rand(1, 1);
%     x2 = rand(1, 1);
%     x3 = rand(1, 1);
%     x = [x1, x2, x3];
%     [r1, i1] = max(x);
%     [r3, i3] = min(x);
%     x([i1, i3]) = 0;
%     r2 = max(x);
%     r1 = 1.5 * r1;
%     if norm(v1 - v2) > r1 && norm(v1 - v3) > r1 &&  norm(v2 - v3) > r2
%         break;
%     end
% end

normal = cross(v1 - v2, v1 - v3);
normal = normal / norm(normal);

c1 = v1 + r1 * normal;
c2 = v2 + r2 * normal;
c3 = v3 + r3 * normal;

%% Compute the tangent plane

c4 - c1 = 

% h = (c1 - c2)' * (c3 - c2) / norm(c3 - c2);
% H = c2 + h * (c3 - c2) / norm(c3 - c2);
% 
% figure; hold on;
% mypoint(H, 'r');
% myline(c1, H, 'r');
% 
% w = sqrt(norm(c1 - c2)^2 - (r1 - r2)^2);
% f  = sqrt(w^2 - h^2);
% beta = atan((r1 - r2)/f);
% j = c1 - H;
% j = j / norm(j);
% 
% k = rotate_around_axis(c3 - c2, j, -beta);
% l1 = H + k * f;
% 
% new_normal = (l1 - c1) / norm(l1 - c1);
% mypoint(l1, 'b');
% myline(H, l1, 'b');
% myline(c1, l1, 'b');
% myline(c1, v1, 'k');


% orange = [0.9, 0.5, 0];
% 
% l1_true = c1 - (r1 - r2) * normal;
% myline(c1, l1_true, orange);
% myline(c2, l1_true, orange);
% myline(c3, l1_true, orange);







%% diplay lines
myline(c1, c2, 'm');
myline(c1, c3, 'm');
myline(c2, c3, 'm');
mypoint(v1, 'k');
mypoint(v2, 'k');
mypoint(v3, 'k');


%% Display spheres
n = 50;
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
    alpha(0.4); grid off; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
    
end

% distances = zeros(N, 1);
% points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
% for i = 1:N
%     p = points(i, :)';   
%     distances(i) = (p - v1)' * normal;
% end
% distances = reshape(distances, size(x));
% color = 'g';
% h = patch(isosurface(x, y, z, distances,0));
% isonormals(x, y, z, distances, h);
% set(h,'FaceColor',color,'EdgeColor','none');
% alpha(0.4); grid off; view([1,1,1]);
% axis equal; camlight; lighting gouraud;