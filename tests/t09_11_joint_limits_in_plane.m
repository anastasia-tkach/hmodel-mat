clc; close all; clear; D = 3;
data_path = '_data/htrack_model/temp/';
mode = 'joint_limits';
skeleton = true;

%% Get model
segments = create_ik_model(mode);

% a = [0; 1; 0];
% for i = 1:length(segments)
%     A = segments{i}.local(1:3, 1:3);
%     b = A * a;
%     B = vrrotvec2mat(vrrotvec(a, b));
%     segments{i}.local(1:3, 1:3) = B;
%     segments{i}.global(1:3, 1:3) = B;
% end

for i = 3:length(segments)
    segments{i}.local(1:3, 1:3) = eye(3, 3);
end

theta = zeros(26, 1);
theta([8, 9, 12]) = -0.6; theta(4:6) = 0;
% theta(11) = 1;

[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);

%% Compute the place
[normal, ~, center] = affine_fit(centers(1:4));

e = [0; 1; 0]; f = [1; 0; 0];

a = (centers{6} - centers{8}) / norm(centers{6} - centers{8});
b = (centers{7} - centers{8}) / norm(centers{7} - centers{8});

u = (centers{3} - centers{4}) / norm(centers{3} - centers{4});
v = normal;

G = fit_svd_rotation([e'; f'], [a'; b']);
G = fit_svd_rotation([(G * a)'; (G * b)'], [(G * u)'; (G * v)']);

theta = SpinCalc('DCMtoEA132', G, 1e-10, 0) / 180 * pi;
for h = 1:3, if abs(theta(h)) > pi, theta(h) = theta(h) - 2 * pi; end; end
theta

vrrotvec(parent_edge, initial)

% w = cross(u, v);
% B = [u'; w'];

% for k = 1:4
%     projections{k} = B * centers{k};    
% end
% 
% figure; hold on; axis equal; axis off;
% for i = 1:4
%     myline(projections{1}, projections{2}, 'b');
%     myline(projections{2}, projections{3}, 'b');
%     myline(projections{3}, projections{4}, 'b');
% end
% 
% e = projections{1} - projections{2};
% d = projections{2} - projections{3};
% c = cross(a, b); c = B * c; s = vrrotvec2D(d, c);
% theta1 = vrrotvec2D(d, e);
% theta1 = - theta1 * sign(s);
% disp(theta1);
% 
% 
% e = projections{2} - projections{3};
% d = projections{3} - projections{4};
% c = cross(a, b); c = B * c; s = vrrotvec2D(d, c);
% theta2 = vrrotvec2D(d, e);
% theta2 = - theta2 * sign(s);
% disp(theta2);



%% Display
if skeleton
    figure; axis equal; axis off; hold on;
    for i = 1:length(blocks),
        myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'k');
        if length(blocks{i}) == 3
            myline(centers{blocks{i}(1)}, centers{blocks{i}(3)}, 'k');
            myline(centers{blocks{i}(2)}, centers{blocks{i}(3)}, 'k');
        end
    end
    mypoints(centers, 'k');
    draw_plane(center, normal, 'b', centers(1:4));
    %myline(centers{4}, centers{4} + 10 * normal, 'r');
    %myline(centers{8}, centers{8} + 10 * (centers{6} - centers{8}) / norm(centers{6} - centers{8}), 'r');
    %myline(centers{8}, centers{8} + 10 * (centers{7} - centers{8}) / norm(centers{7} - centers{8}), 'r');
    %myline(centers{4}, centers{4} + 10 * w, 'g');
    %myline(centers{4}, centers{4} + 10 * v, 'g');
else
    display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
end

