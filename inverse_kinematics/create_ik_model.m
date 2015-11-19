function [segments] = create_ik_model(mode)

Rx = @(alpha) [1, 0, 0, 0;
    0, cos(alpha), -sin(alpha), 0;
    0, sin(alpha), cos(alpha), 0;
    0, 0, 0, 1];

switch mode
    case 'hand'
        segments = segments_parameters();
    case 'finger'
        segments = finger_segments_parameters();
    case 'palm_finger'
        segments = palm_finger_segments_parameters();
    case 'joint_limits'
        segments = palm_finger_segments_parameters();
end

factor = 0.8116;
for k = 1:length(segments)
    segments{k}.local(1:3, 4) =  factor * segments{k}.local(1:3, 4);
    segments{k}.radius1 = factor * segments{k}.radius1;
    segments{k}.radius2 = factor * segments{k}.radius2;
    segments{k}.length = factor * segments{k}.length;
end


for i = 1:length(segments)
    l = segments{i}.length;
    r1 = segments{i}.radius1;
    r2 = segments{i}.radius2;
    r = segments{i}.ratio;
    [Vertices, ~] = get_initial_segment(l, r1, r2, r);
    Vertices = transform(Vertices, Rx(pi/2)');
    segments{i}.V = Vertices;
end
segments = update_transform(segments, 1);