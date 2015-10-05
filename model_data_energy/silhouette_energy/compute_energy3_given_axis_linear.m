function [pose, f, Jc, Jr] = compute_energy3_given_axis_linear(pose, radii, blocks, view_axis, H, W, D)

num_points = length(pose.model_points);
indices = pose.model_indices;
model_points = pose.model_points;
centers = pose.centers;

P = pose.P;
rendered_data = pose.rendered_data;
distance_transform = pose.distance_transform;
gradient_directions = pose.gradient_directions;

f = zeros(2 * num_points, 1);
Jc = zeros(2 * num_points, length(centers) * D);
Jr = zeros(2 * num_points, length(centers));
pose.model_projections_2D = cell(num_points, 1);
pose.model_points_2D = cell(num_points, 1);

[tangent_gradients] = blocks_tangent_points_gradients(centers, blocks, radii, D);

%% Compute tangent points
tangent_gradient = [];
for i = 1:num_points
    if isempty(indices{i}), continue; end
    
    %% Determine current block
    if length(indices{i}) == 3
        for b = 1:length(blocks)
            if (length(blocks{b}) < 3), continue; end
            abs_index = [abs(indices{i}(1)), abs(indices{i}(2)), abs(indices{i}(3))];
            indicator = ismember(blocks{b}, abs_index);
            if sum(indicator) == 3
                tangent_gradient = tangent_gradients{b};
                break;
            end
        end
    end
    
    [f_i, df_i, m_i, x_i] = energy3_linear(centers, radii, model_points{i}, indices{i}, tangent_gradient, P, view_axis, H, W, rendered_data, distance_transform, gradient_directions);
    if isempty(f_i), continue; end
    pose.model_points_2D{i} = m_i;
    pose.model_projections_2D{i} = x_i;
    
    f(2 * i - 1:2 * i) = f_i;
    %% Case 1
    if length(indices{i}) == 1
        Jc(2 * i - 1:2 * i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = df_i.dc1;
        Jr(2 * i - 1:2 * i, indices{i}(1)) = df_i.dr1;
    end
    %% Case 2
    if length(indices{i}) == 2
        Jc(2 * i - 1:2 * i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = df_i.dc1;
        Jc(2 * i - 1:2 * i, D * indices{i}(2) - D + 1:D * indices{i}(2)) = df_i.dc2;
        Jr(2 * i - 1:2 * i, indices{i}(1)) = df_i.dr1;
        Jr(2 * i - 1:2 * i, indices{i}(2)) = df_i.dr2;
    end
    %% Case 3
    if length(indices{i}) == 3
        Jc(2 * i - 1:2 * i, D * abs(indices{i}(1)) - D + 1:D * abs(indices{i}(1))) = df_i.dc1;
        Jc(2 * i - 1:2 * i, D * abs(indices{i}(2)) - D + 1:D * abs(indices{i}(2))) = df_i.dc2;
        Jc(2 * i - 1:2 * i, D * abs(indices{i}(3)) - D + 1:D * abs(indices{i}(3))) = df_i.dc3;
        Jr(2 * i - 1:2 * i, abs(indices{i}(1))) = df_i.dr1;
        Jr(2 * i - 1:2 * i, abs(indices{i}(2))) = df_i.dr2;
        Jr(2 * i - 1:2 * i, abs(indices{i}(3))) = df_i.dr3;
    end
end
settings = 1;
%display_energy3(pose, settings)
