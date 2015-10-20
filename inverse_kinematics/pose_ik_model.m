function [segments, joints] = pose_ik_model(segments, t, display, mode)


switch mode
    case 'hand'
        joints = joints_parameters(t);
        order = [1, 2, 3, 4, 5, 6, 8 7 9 10 12 11 13 14 16 15 17 18 20 19 21 22 24 23 25 26];
    case 'finger'
        joints = finger_joints_parameters(t);
        order = [1, 2, 3, 4, 5, 6, 7, 8];
end

for i = order
    segment = segments{joints{i}.segment_id};
    T = [];
    switch joints{i}.type
        case 'R'
            T = segment.local * makehgtform('axisrotate', joints{i}.axis, joints{i}.value);
        case 'T'
            T = segment.local * makehgtform('translate', joints{i}.axis * joints{i}.value);
    end
    segments{joints{i}.segment_id}.local = T;
    segments = update_transform(segments, joints{i}.segment_id);
end

%% Display the model
if display
    [~, Triangles] = get_initial_segment(1, 1, 1, 1);
    figure; hold on; axis equal;
    for i = 1:length(segments)
        V = transform(segments{i}.V, segments{i}.global);
        draw_segment(V , Triangles);
    end
    campos([10, 160, -1500]);
    grid off; axis off;
end