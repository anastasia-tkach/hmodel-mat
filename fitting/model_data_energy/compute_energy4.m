function [pose] = compute_energy4(pose, blocks, radii, settings, display)

if settings.energy4 == false, return; end

%% Sample the model
view_axes = {'X', 'Y', 'Z'};
pose.model_points  = [];
for v = 1:settings.D
    view_axis = view_axes{v};
    for side = {'front', 'back'}
        
        %% Render model and data
        [raytracing_matrix, ~, camera_center] = get_raytracing_matrix(pose.centers, radii, pose.data_bounding_box, view_axis, settings, side);
        pose = render_model(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        
        %% Get model points
        [I, J] = find((pose.rendered_model(:, :, 3) > - settings.RAND_MAX));
        N = length(pose.model_points);
        pose.model_points = [pose.model_points; cell(length(I), 1)];
        for k = 1:length(I),
            pose.model_points{N + k} = squeeze(pose.rendered_model(I(k), J(k), :));
        end
    end
end

%% Get closest data points
[pose.model_indices, pose.projections, ~] = compute_projections(pose.model_points, pose.centers, blocks, radii);
[pose.model_normals] = compute_model_normals_temp(pose.centers, blocks, radii, pose.model_points, pose.model_indices);
pose.closest_data_points = cell(length(pose.model_points), 1);
pose.closest_data_normals = cell(length(pose.model_points), 1);

for i = 1:length(pose.model_points)
    p = pose.model_points{i};
    index = knnsearch(pose.kdtree, p', 'K', 1);
    q = pose.points{index};
    n = pose.normals{index};
    %pose.closest_data_points{i} = p + (q - p)' * n * n;
    pose.closest_data_points{i} = q;
    pose.closest_data_normals{i} = n;

    if (n' * pose.model_normals{i}) < settings.discard_threshold
        pose.model_points{i} = [];
        pose.closest_data_points{i} = [];
        pose.closest_data_normals{i} = [];
        pose.model_normals{i} = [];
        pose.model_indices{i} = [];
    end
end
pose.model_points = pose.model_points(~cellfun('isempty', pose.model_points));
pose.model_indices = pose.model_indices(~cellfun('isempty', pose.model_indices));
pose.closest_data_points = pose.closest_data_points(~cellfun('isempty', pose.closest_data_points));
pose.closest_data_normals = pose.closest_data_normals(~cellfun('isempty', pose.closest_data_normals));
pose.model_normals = pose.model_normals(~cellfun('isempty', pose.model_normals));

%% Compute Jacobian
centers = pose.centers;
model_points = pose.model_points;
data_points = pose.closest_data_points;
model_indices = pose.model_indices;

[f, Jc, Jr] = jacobian_fitting_normal(centers, radii, blocks, model_points, model_indices, data_points, settings.D);

[fn, Jcn, Jrn] = compute_normal_distance(centers, pose.model_normals, f, Jc, Jr, settings.D);
%[fn, Jcn, Jrn] = compute_normal_distance(centers, pose.closest_data_normals, f, Jc, Jr, settings.D);
pose.f4 = fn; pose.Jc4 = Jcn; pose.Jr4 = Jrn;

%% Display
correspondences = cell(length(pose.closest_data_normals));
others = cell(length(pose.closest_data_normals));
for i = 1:length(pose.closest_data_normals)
    correspondences{i} = pose.model_points{i} + pose.f4(i) * pose.model_normals{i};
    others{i} = pose.model_points{i} + pose.f4(i) * pose.closest_data_normals{i};
end
if (display)
    data_color = [0.65, 0.1, 0.5];
    model_color = [0, 0.7, 1];
    display_result(pose.centers, [], [], blocks, radii, false, 0.7);   
    mypoints(correspondences, data_color);
    mypoints(pose.model_points, model_color);
    mylines(pose.model_points, correspondences, [0.75, 0.75, 0.75]);
    mylines(pose.model_points, others, [0.4, 0.4, 0.4]);
    mypoints(pose.closest_data_points, 'k');
    drawnow;
end
