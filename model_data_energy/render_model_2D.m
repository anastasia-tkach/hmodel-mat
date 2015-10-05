function [pose] = render_model_2D(pose, blocks, radii, camera_matrix, camera_center, settings)
H = settings.H;

centers = pose.centers;
M = camera_matrix;
p = camera_center;

tangent_points = blocks_tangent_points(centers, blocks, radii);

%display_result_2D(pose, blocks, radii, false);

%% Render model
RAND_MAX = 32767;
U = -RAND_MAX * ones(H, 1);
D = -RAND_MAX * ones(H, 1);
for n = 1:H
    d = M * [n; 1];
    d = d / norm(d);
    i = ray_model_intersection(centers, blocks, radii, tangent_points, p, d);
    if (norm(i) < Inf)
        U(n) = i(1);
        D(n) = i(2);
        %mypoint(i, 'r');
    end
end
pose.rendered_model = zeros(H, 2);
pose.rendered_model(:, 1) = U;
pose.rendered_model(:, 2) = D;



