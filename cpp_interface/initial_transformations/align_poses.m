function [poses] = align_poses(poses, radii, blocks, names_map, display)

num_poses = length(poses);
reference_index = 2;
pose = poses{reference_index};
poses(reference_index) = [];

palm_indices = [
    %names_map('palm_pinky'), names_map('palm_ring'), names_map('palm_middle'), names_map('palm_index'), names_map('palm_thumb'), ...
    names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];

for p = 1:num_poses-1
    P = cell(length(palm_indices), 1);
    Q = cell(length(palm_indices), 1);
    for i = 1:length(palm_indices)
        P{i} = pose.centers{palm_indices(i)};
        Q{i} = poses{p}.centers{palm_indices(i)};
    end
    [M, scaling] = find_rigid_transformation(P, Q, true);
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = transform(poses{p}.centers{i}, M);
        radii{i} = radii{i} * scaling;
    end
    
    if display
        %display_result(poses{1}.centers, [], [], blocks, radii, false, 0.5, 'big');
        %display_result(poses{p}.centers, [], [], blocks, radii, false, 0.5, 'none');
        figure; hold on; axis off; axis equal;
        display_skeleton(pose.centers, radii, blocks, [], false, 'b');
        display_skeleton(poses{p}.centers, radii, blocks, [], false, 'r');
    end
end

poses = [poses(1 : reference_index - 1); {pose}; poses(reference_index : end)];
