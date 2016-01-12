function [centers, htrack_centers] = aling_htrack_hmodel_frames(centers, htrack_centers, names_map, key_points_names, verbose, D)

points = cell(length(key_points_names), 1);
for i = 1:length(key_points_names)
    points{i} = centers{names_map(key_points_names{i})};
end

[hmodel_frame, hmodel_translation] = compute_principle_axis(points, verbose);
[htrack_frame, htrack_translation] = compute_principle_axis(htrack_centers([21:24]), verbose);

hmodel_orientation = hmodel_frame(:, 2)' * (centers{names_map('thumb_bottom')} - hmodel_translation) > 0;
htrack_orientation = htrack_frame(:, 2)' * (htrack_centers{19} - htrack_translation) > 0;

if hmodel_orientation && htrack_orientation == false
    hmodel_frame(:, 2) = -hmodel_frame(:, 2);
    hmodel_frame(:, 3) = -hmodel_frame(:, 3);
end

if verbose
    factor = 10;
    myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 1), 'm');
    myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 2), 'm');
    myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 3), 'm');
    myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 1), 'm');
    myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 2), 'm');
    myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 3), 'm');
end

%% Find hmodel transformation
rotation = find_svd_rotation(htrack_frame, hmodel_frame);
R = eye(D + 1, D + 1); R(1:D, 1:D) = rotation;
T1 = makehgtform('translate', -hmodel_translation);
T2 = makehgtform('translate', htrack_translation);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, T2 * R * T1);
end

%% Display
if verbose
    display_result(centers, [], [], blocks, radii, false, 0.3, 'big');
    display_skeleton(centers, radii, blocks, [], false, []);
    segments = create_ik_model('hand');
    [segments, joints] = pose_ik_model(segments, theta, verbose, 'hand');
    [htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');
    view([180, -90]); camlight; drawnow; 
end