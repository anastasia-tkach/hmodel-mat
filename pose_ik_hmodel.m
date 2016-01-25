function [centers, joints, segments] = pose_ik_hmodel(theta, centers, names_map, segments)

D = 3;
up = [0; 1; 0];

%figure; axis off; axis equal; hold on;

% for i = 2:length(segments)    
%     segments{i}.local(1:D, 1:D) = eye(D, D);
% end

[segments, joints] = pose_ik_model(segments, theta, false, 'hand');

for i = 1:length(segments)
    centers{names_map(segments{i}.name)} = segments{i}.global(1:D, D + 1);
    if isfield(segments{i}, 'end_name')
        centers{names_map(segments{i}.end_name)} = ...
            centers{names_map(segments{i}.name)} + segments{i}.global(1:D, 1:D) * segments{i}.length * up;
    end
    if isfield(segments{i}, 'additional_name')       
        centers{names_map(segments{i}.additional_name)} = ...
           centers{names_map(segments{i}.name)} + segments{i}.global(1:D, 1:D) * segments{i}.additional_length * up;
    end
end

%% Pose rigid centers
for i = 1:length(segments{1}.rigid_names)
    index = names_map(segments{1}.rigid_names{i});
    T = segments{1}.global(1:D, 1:D) * segments{1}.offsets{i};
    centers{index} = centers{names_map(segments{1}.name)} + T;
end
