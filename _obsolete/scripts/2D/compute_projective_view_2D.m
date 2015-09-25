function [pose] = compute_projective_view_2D(pose, blocks, radii, W, H, view_axis, closing_radius)

[bounding_box.min_x, bounding_box.min_y, ~, bounding_box.max_x, bounding_box.max_y, ~] = ...
    compute_bounding_box(pose.centers_3D, radii);

H = 80; W = 40;
xm = linspace(bounding_box.min_x, bounding_box.max_x, W);
ym = linspace(bounding_box.min_y, bounding_box.max_y, H);
[x, y] = meshgrid(xm,ym); N = numel(x);
model_points = [reshape(x, N, 1), reshape(y, N, 1), zeros(N, 1)];
c1 = pose.centers_3D{1};
c2 = pose.centers_3D{2};
r1 = radii{1}; r2 = radii{2};
distances = distance_to_model_convsegment(c1, c2, r1, r2, model_points');
distances = reshape(distances, size(x));
pose.model_points = [];
pose.rendered_model_points = [];
rendered_model = zeros(H, W);
rendered_model_U = zeros(H, W);
rendered_model_V = zeros(H, W);
k = 1;
for i = 1:H
    for j = 1:W
        if (distances(i, j) <= 0)
            pose.model_points{k} = [x(i, j); y(i, j)]; 
            pose.rendered_model_points{k} = [j; i];
            rendered_model(i, j) = 1;
            rendered_model_U(i, j) = x(i, j);
            rendered_model_V(i, j) = y(i, j);
            k = k + 1;
        end
    end
end

% mypoints(pose.model_points, 'b');

%% Render data
rendered_data = zeros(H, W);
pose.rendered_data_points = cell(length(pose.points), 1);
for i = 1:length(pose.points_2D)
    p = pose.points_2D{i};   
    m = zeros(2, 1);
    m(1) = (p(1) - bounding_box.min_x) * W / (bounding_box.max_x - bounding_box.min_x);
    m(2) = (p(2) - bounding_box.min_y) * H / (bounding_box.max_y - bounding_box.min_y);
    pose.rendered_data_points{i} = m;
    if (m(1) < 1 || m(1) > W || m(2) < 1 || m(2) > H), continue; end
    rendered_data(round(m(2)), round(m(1))) = 1;
end

% figure; mypoints(pose.rendered_data_points, 'm'); hold on;
% mypoints(pose.rendered_model_points, 'b'); axis equal;
% xlim([0 W]); ylim([0 H]);

rendered_data = imclose(rendered_data, strel('disk', closing_radius, 0));
% figure; imshow(rendered_data, []); 
% figure; imshow(rendered_model, []); 
[distance_transform] = dtform(double(rendered_data));
[~, gradient_directions] = imgradient(distance_transform);

% rendered_intersection = zeros(H, W, 3);
% rendered_intersection(:, :, 1) = rendered_model;
% rendered_intersection(:, :, 2) = rendered_data;
% figure; imshow(rendered_intersection); hold on;

%% Get 2.5D model
% figure; mypoints(pose.points_2D, 'm'); hold on;
% mypoints(pose.model_points, 'b'); axis equal;
[I, J] = find((rendered_model == 1) & (rendered_data == 0));
pose.wrong_model_points = cell(length(I), 1);

for k = 1:length(I)
    pose.wrong_model_points{k} = [rendered_model_U(I(k), J(k)); rendered_model_V(I(k), J(k))];
end

pose.rendered_model = rendered_model;
pose.rendered_data = rendered_data;
pose.gradient_directions = gradient_directions;
pose.distance_transform = distance_transform;
