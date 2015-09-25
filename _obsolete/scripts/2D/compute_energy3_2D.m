function [pose, f, Jc, Jr] = compute_energy3_2D(pose, radii, blocks, view_axis, settings)
H = settings.H; W = settings.W; D = settings.D;

num_points = length(pose.model_points);
indices = pose.model_indices;
model_points = pose.model_points;
centers = pose.centers;

P = pose.P;
rendered_data = pose.rendered_data;
distance_transform = pose.distance_transform;
gradient_directions = pose.gradient_directions;

f = zeros(num_points, 1);
Jc = zeros(num_points, length(centers) * D);
Jr = zeros(num_points, length(centers));
pose.model_projections_2D = cell(num_points, 1);
pose.model_points_2D = cell(num_points, 1);

%% Compute tangent points
tangent_gradient = [];
for i = 1:num_points
    if isempty(indices{i}), continue; end
    [f_i, df_i, m_i, x_i] = energy3_2D(centers, radii, model_points{i}, indices{i}, tangent_gradient, P, view_axis, rendered_data, distance_transform, gradient_directions, settings);
    if isempty(f_i), continue; end
    pose.model_points_2D{i} = m_i;
    pose.model_projections_2D{i} = x_i;
    
    f(i) = f_i;
    %% Case 1
    if length(indices{i}) == 1
        Jc(i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = df_i.dc1;
        Jr(i, indices{i}(1)) = df_i.dr1;
    end
    %% Case 2
    if length(indices{i}) == 2
        Jc(i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = df_i.dc1;
        Jc(i, D * indices{i}(2) - D + 1:D * indices{i}(2)) = df_i.dc2;
        Jr(i, indices{i}(1)) = df_i.dr1;
        Jr(i, indices{i}(2)) = df_i.dr2;
    end    
end