% clear;
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

centers{1} = c1; centers{2} = c2; centers{3} = c3;
radii{1} = r1; radii{2} = r2; radii{3} = r3;
blocks{1} = [1, 2, 3]; poses{1}.centers = centers;

[bounding_box.min_x, bounding_box.min_y, bounding_box.min_z, bounding_box.max_x, bounding_box.max_y, bounding_box.max_z] = ...
    compute_bounding_box(centers, radii);
Mean = [mean([bounding_box.min_x, bounding_box.max_x]); mean([bounding_box.min_y, bounding_box.max_y]); mean([bounding_box.min_z, bounding_box.max_z])];
tangent_points = blocks_tangent_points(centers, blocks, radii);

v1 = tangent_points{1}.v1; v2 = tangent_points{1}.v2; v3 = tangent_points{1}.v3;
u1 = tangent_points{1}.u1; u2 = tangent_points{1}.u2; u3 = tangent_points{1}.u3;

%% Camera parameters
H = 480; W = 640;
figure; hold on;
position = get(gcf, 'position');
set(gcf, 'position', [position(1), position(2), W, H]);
camproj('perspective'); axis image; axis off;
set(gca, 'Units', 'pixels', 'Position', [1 1 W H]);
display_result_convtriangles(poses{1}, blocks, radii, false);
C = campos';
%camtarget((C - Mean)');
model = frame2im(getframe); 

%%
fov = camva;
%C = campos';
T = camtarget;
w = (Mean - C);

w = w / norm(w);
z = [0; 0; 1];
v = z - (w' * z) * w;
v = v / norm(v);
u = cross(v, w);
u = u / norm(u);

p = C;
f = H/2/tand(fov/2);
S = f * (bounding_box.max_x - bounding_box.min_x) / C(3) / H;
n0 = W/2;
m0 = H/2;
A = zeros(3, 3);
A(1, 1) = - S / f;
A(2, 2) = - S / f;
A(1, 3) = n0 * S / f;
A(2, 3) = m0 * S / f;
A(3, 3) = 1;
D = -1.5 * ones(H, W);
skip = 5;
%% Display rays

% mypoint(C, 'r');
% myline(C, C  + w * norm(C), 'r');

for n = 1:skip:W    
    for m = 1:skip:H
        d = [u, v, w] * A * [n; m; 1];
        d = d / norm(d);
        % myline(C, C + d * norm(C), 'c');
        i = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, p, d);        
        if (norm(i) < Inf)
            D(m, n) = i(3);            
        end
    end
end


figure; imshow(D(1:skip:H, 1:skip:W), []);
% figure; imshow(model); axis on;
return;


%% Convsegment
clear;
D = 3;
c1 = rand(D ,1); c2 = rand(D ,1);
x1 = rand; x2 = rand;
r1 = max(x1, x2); r2 = min(x1, x2);

centers{1} = c1; centers{2} = c2; radii{1} = r1; radii{2} = r2;
blocks{1} = [1, 2]; poses{1}.centers = centers;
n = (c2 - c1)/norm(c2 - c1);

%% Find planes
beta = asin((r1 - r2) /norm(c1 - c2));
eta1 = r1 * sin(beta);
s1 = c1 + eta1 * n;
eta2 = r2 * sin(beta);
s2 = c2 + eta2 * n;

[bounding_box.min_x, bounding_box.min_y, bounding_box.min_z, bounding_box.max_x, bounding_box.max_y, bounding_box.max_z] = ...
    compute_bounding_box(centers, radii);
display_result_convtriangles(poses{1}, blocks, radii, false);

% draw_plane(s1, n, 'g', bounding_box);
% draw_plane(s2, n, 'g', bounding_box);

p = [1.2; 1.2; 1.2]; v = [-1; -1; -1]; v = v/norm(v);
% mypoint(p, 'm');
myline(p, p + 2 * v, 'm');

z = c1 + (c2 - c1) * r1 / (r1 - r2);
h = norm(z - c1);
alpha = atan(r1 / h);

[i] = ray_convsegment_intersection(c1, c2, r1, r2, p, v);

mypoint(i, 'k');
mypoint(c1, 'k');
myline(c1, z, 'b');
load q;
w = c1 + r1 * q;
myline(c1, w, 'r');
myline(w, z, 'r');









