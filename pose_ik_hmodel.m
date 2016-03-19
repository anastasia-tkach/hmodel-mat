function [centers, segments] = pose_ik_hmodel(theta, centers, names_map, segments, joints)

D = 3;

order = [1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 12, 11, 13, 14, 16, 15, 17, 18, 20, 19, 21, 22, 24, 23, 25, 26];

%% Pose segments
for i = order
    segment = segments{joints{i}.segment_id};
    T = [];
    switch joints{i}.type
        case 'R'
            T = segment.local * makehgtform('axisrotate', joints{i}.axis, theta(i));
        case 'T'
            T = segment.local * makehgtform('translate', joints{i}.axis * theta(i));
    end    
    if ~isempty(segment.parent_id)
        segment.local = T;
        segment.global = segments{segment.parent_id}.global * T;
    else
        segment.local = T;
        segment.global = T;
    end
    segments{joints{i}.segment_id} = segment;
end


%% Pose centers
for i = 1:length(segments)
    centers{names_map(segments{i}.name)} = segments{i}.global(1:D, D + 1);
    if isfield(segments{i}, 'rigid_names')
        for j = 1:length(segments{i}.rigid_names)
            index = names_map(segments{i}.rigid_names{j});
            T = segments{i}.global(1:D, 1:D) * segments{i}.offsets{j};
            centers{index} = centers{names_map(segments{i}.name)} + T;
        end
    end
end

