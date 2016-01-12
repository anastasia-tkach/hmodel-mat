% % [centers, radii, blocks] = get_random_convsegment(D);
% % c1 = centers{1}; c2 = centers{2};
% % r1 = radii{1}; r2 = radii{2};
%
% [centers, radii, blocks] = get_random_convtriangle();
% c1 = centers{1}; c2 = centers{2}; c3 = centers{3};
% r1 = radii{1}; r2 = radii{2}; r3 = radii{3};
%
% alpha = rand;
% t = alpha * c1 + (1 - alpha) * c2;
% u = (c1 - c2) / norm(c1 - c2);
% p = t + [u(2); - u(1); 0];
% p = randn(3, 1);
% v = t - p;
%
% %[i, normal] = ray_convsegment_intersection(c1, c2, r1, r2, p, v);
%
% tangent_points = blocks_tangent_points(centers, blocks, radii);
% tangent_point = tangent_points{1};
% v1 = tangent_point.v1; v2 = tangent_point.v2; v3 = tangent_point.v3;
% u1 = tangent_point.u1; u2 = tangent_point.u2; u3 = tangent_point.u3;
% [i, normal] = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, p, v);
%
% %% Display
% display_result(centers, [], [], blocks, radii, false, 0.5);
% % myline(c1, c2, 'b'); mypoint(c1, 'b'); mypoint(c2, 'b'); mypoint(c3, 'b');
% mypoint(i, 'm');
% myline(i, i + 0.3 * normal, 'c');
%
% %% Compare
% [model_indices, model_points, ~] = compute_projections({i}, centers, blocks, radii);
% [normals] = compute_model_normals_temp(centers, blocks, radii, model_points, model_indices);
% myline(i, i + 0.3 * normals{1}, 'k');
%
% [V, F] = readOBJ('C:\Users\tkach\Desktop\shading-build\tangle_cube.obj');

%% Sphere in parametric form
%close all;
theta = linspace(0, pi, 30);
phi = linspace(0, pi, 20);

figure; axis equal; hold on; axis off;
p = {};
up = [0; 1; 0];
direction = [1; 0; 0];
for i = 1:length(theta)
    for j = 1:length(phi)
        x = cos(phi(j)) * [1; 0; 0];
        y = sin(theta(i)) * sin(phi(j)) * [0; 1; 0];
        z = cos(theta(i)) * sin(phi(j)) * [0; 0; 1];
        p{end + 1} = x + y + z;
        camera_direction =  - p{end};
        camera_up = up - (camera_direction' * up) * camera_direction;
        camera_up = camera_up / norm(camera_up);
        
        if camera_direction' * up < 0
            if direction' * camera_up < 0
                camera_up = -camera_up;
            end
            myline(p{end}, p{end} + 0.1 * camera_up, 'g');
        else
            if direction' * camera_up > 0
                camera_up = -camera_up;
            end
        end
        
    end
end
mypoints(p, 'b');


