function [] = display_energy3(pose, settings)

RAND_MAX = 32767;

% view_axes = {'X', 'Y', 'Z'};
% for v = 1:length(view_axes)
%
%     view_axis = view_axes{v};
%
%     switch view_axis
%         case 'X'
%             if (settings.energy3x == false), continue; end
%             rendered_model = pose.rendered_model_X;
%             rendered_data = pose.rendered_data_X;
%             model_points_2D = pose.model_points_2D_X;
%             model_projections_2D = pose.model_projections_2D_X;
%         case 'Y'
%             if (settings.energy3y == false), continue; end
%             rendered_model = pose.rendered_model_Y;
%             rendered_data = pose.rendered_data_Y;
%             model_points_2D = pose.model_points_2D_Y;
%             model_projections_2D = pose.model_projections_2D_Y;
%         case 'Z'
%             if (settings.energy3z == false), continue; end
%             rendered_model = pose.rendered_model_Z;
%             rendered_data = pose.rendered_data_Z;
%             model_points_2D = pose.model_points_2D_Z;
%             model_projections_2D = pose.model_projections_2D_Z;
%     end

rendered_model = pose.rendered_model;
rendered_data = pose.rendered_data;
model_points_2D = pose.model_points_2D;
model_projections_2D = pose.model_projections_2D;

%% Display
rendered_intersection = zeros(size(rendered_model));
rendered_intersection(:, :, 1) = (rendered_model(:, :, 3) > -RAND_MAX);
rendered_intersection(:, :, 2) = rendered_data;
figure; imshow(rendered_intersection); hold on;
M = zeros(length(model_points_2D), 2);
X = zeros(length(model_points_2D), 2);
L = zeros(length(model_points_2D) * 3, 2);
k = 1;

for i = 1:length(model_points_2D)
    if isempty(model_points_2D{i}), continue; end
    M(k, :) = model_points_2D{i}';
    X(k, :) = model_projections_2D{i}';
    L(3 * (k - 1) + 1, :) = model_points_2D{i}';
    L(3 * (k - 1) + 2, :) = model_projections_2D{i}';
    L(3 * (k - 1) + 3, :) = [NaN, NaN];
    k = k + 1;
end
k = k - 1;
scatter(M(1:k, 1), M(1:k, 2), 10, 'o', 'filled', 'w');
scatter(X(1:k, 1), X(1:k, 2), 10, 'o', 'filled', 'b');
line(L(1:3*k, 1), L(1:3*k, 2), 'lineWidth', 2, 'color', [0.1, 0.8, 0.8]);

% end
