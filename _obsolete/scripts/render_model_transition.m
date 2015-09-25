function [D] = render_model_transition(centers, blocks, radii)

bounding_box = ...
    compute_model_bounding_box(centers, radii);
Mean = [mean([bounding_box.min_x, bounding_box.max_x]); mean([bounding_box.min_y, bounding_box.max_y]); mean([bounding_box.min_z, bounding_box.max_z])];
tangent_points = blocks_tangent_points(centers, blocks, radii);
pose.centers = centers;

%% Camera parameters
H = 480; W = 640;

display_result_convtriangles(pose, blocks, radii, false);
position = get(gcf, 'position');
set(gcf, 'position', [position(1), position(2), W, H]);
camproj('perspective'); axis image; axis off;
set(gca, 'Units', 'pixels', 'Position', [1 1 W H]);
C = campos';
fov = camva;
w = (Mean - C);
close;

w = w / norm(w); z = [0; 0; 1];
v = z - (w' * z) * w; v = v / norm(v);
u = cross(v, w); u = u / norm(u);

p = C; f = H/2/tand(fov/2);
S = f * (bounding_box.max_x - bounding_box.min_x) / C(3) / H;
n0 = W/2; m0 = H/2;
A = zeros(3, 3);
A(1, 1) = - S / f; A(2, 2) = - S / f;
A(1, 3) = n0 * S / f; A(2, 3) = m0 * S / f;
A(3, 3) = 1;
P = [u, v, w] * A;

D = render_model_matlab(centers, blocks, radii, tangent_points, W, H, P, p);






