function [segments, joints] = pose_ik_model(segments, t, display, mode)


switch mode
    case 'hand'
        joints = joints_parameters(t);
        order = [1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 12, 11, 13, 14, 16, 15, 17, 18, 20, 19, 21, 22, 24, 23, 25, 26];
    case 'palm_finger'
        joints = palm_finger_joints_parameters(t);
        order = [1, 2, 3, 4, 5, 6, 8, 7, 9, 10];
    case 'finger'
        joints = finger_joints_parameters(t);
        order = [1, 2, 3, 4, 5, 6, 7, 8];
    case 'joint_limits'
        joints = joint_limits_parameters(t);
        order = 1:14;
end

for i = order
    segment = segments{joints{i}.segment_id};
    T = [];
    %switch joints{i}.axis
    %    case 'X'
    %        joints{i}.axis_vector = [1; 0; 0];
    %    case 'Y'
    %        joints{i}.axis_vector = [0; 1; 0];
    %    case 'Z'
    %        joints{i}.axis_vector = [0; 0; 1];
    %end
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
    %figure; hold on;
    first_points = {};
    second_points = {};
    [~, Triangles] = get_initial_segment(1, 1, 1, 1);
    for i = 1:length(segments)
        V = transform(segments{i}.V, segments{i}.global);
        [first, second] = draw_segment(V , Triangles);
        first_points = [first_points, first];
        second_points = [second_points, second];
    end
    
    mylines(first_points, second_points, 0.9 * [196/255, 178/255, 190/255]);
    campos([10, 160, -1500]);
    grid off; axis off;
end