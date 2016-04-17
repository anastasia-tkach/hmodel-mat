function [model_indices, model_points, block_indices] = compute_frontfacing_correspondences(centers, radii, blocks, data_points, names_map, display)

palm_blocks = {
    [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_fold')], ...
    [names_map('palm_ring'), names_map('palm_pinky'), names_map('palm_right')], ...
    [names_map('palm_back'), names_map('palm_ring'), names_map('palm_right')], ...
    [names_map('palm_back'), names_map('palm_ring'), names_map('palm_middle')], ...
    [names_map('palm_back'), names_map('palm_left'), names_map('palm_middle')], ...
    [names_map('palm_left'), names_map('palm_middle'), names_map('palm_index')], ...
    [names_map('pinky_membrane'), names_map('palm_pinky'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('palm_pinky'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('middle_membrane'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('palm_middle'), names_map('middle_membrane')], ...
    [names_map('palm_middle'), names_map('palm_index'), names_map('middle_membrane')], ...
    [names_map('palm_index'), names_map('index_membrane'), names_map('middle_membrane')], ...
    [names_map('thumb_base'), names_map('thumb_fold'), names_map('palm_thumb')], ...
    [names_map('wrist_bottom_left'), names_map('wrist_top_left'), names_map('wrist_top_right')], ...
    [names_map('wrist_bottom_right'), names_map('wrist_bottom_left'), names_map('wrist_top_right')]
    };

fingers_blocks{1} = {[names_map('pinky_middle'), names_map('pinky_top')], ...
    [names_map('pinky_bottom'), names_map('pinky_middle')], ...
    [names_map('pinky_base'), names_map('pinky_bottom')]};
fingers_blocks{2} = {[names_map('ring_top'), names_map('ring_middle')], ...
    [names_map('ring_bottom'), names_map('ring_middle')], ...
    [names_map('ring_bottom'), names_map('ring_base')]};
fingers_blocks{3} = {[names_map('middle_top'), names_map('middle_middle')], ...
    [names_map('middle_bottom'), names_map('middle_middle')], ...
    [names_map('middle_bottom'), names_map('middle_base')]};
fingers_blocks{4} = {[names_map('index_middle'), names_map('index_top')], ...
    [names_map('index_bottom'), names_map('index_middle')], ...
    [names_map('index_base'), names_map('index_bottom')]};
fingers_blocks{5} = {[names_map('thumb_top'), names_map('thumb_additional')], ...
    [names_map('thumb_top'), names_map('thumb_middle')], ...
    [names_map('thumb_bottom'), names_map('thumb_middle')]};


blocks = reindex(radii, blocks);
camera_ray = [0; 0; 1];

tangent_points = blocks_tangent_points(centers, blocks, radii);

model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
model_indices = cell(length(data_points), 1);
b = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    [model_points{i}, model_indices{i}, axis_points{i}, block_indices{i}, ~] = ...
        projeciton_group(p, centers, radii, blocks, tangent_points, [], [], camera_ray, false, false);
end

%% Replace by outline if closer

[outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, camera_ray, names_map, false, true);
[outline_indices, outline_points, outline_blocks_indices, outline_axis_points] = compute_projections_outline(data_points, outline, centers, radii, camera_ray);
for i = 1:length(data_points)
    if isempty(model_points{i}), continue; end
    if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
        model_points{i} = outline_points{i};
        model_indices{i} = outline_indices{i};
        block_indices{i} = outline_blocks_indices{i};
        axis_points{i} = outline_axis_points{i};
    end
end

%% Display
if (display)
    display_result(centers, [], [], blocks, radii, false, 0.6, 'big');
    view([-180, -90]); camlight;
    data_color = [0, 1, 1];
    model_color = 'm';
    mypoints(data_points, data_color);
    mypoints(model_points, model_color);
    mylines(data_points, model_points, [0.6, 0.6, 0.6]);
    for i = 1:length(outline)
        if length(outline{i}.indices) == 2
            myline(outline{i}.start, outline{i}.end, 'y');
        else
            draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.start, outline{i}.end, 'y');
        end
    end
end


