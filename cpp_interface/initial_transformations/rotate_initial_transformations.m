function [centers, phalanges] = rotate_initial_transformations(centers, radii, blocks, phalanges, dofs, theta, names_map)

D = 3;
num_thetas = 29;

%% Rotate centers 
for i = 1:length(phalanges)
    phalanges{i}.local = phalanges{i}.init_local;
end
phalanges = htrack_move(theta, dofs, phalanges);

[centers] = update_centers(centers, phalanges, names_map);

%% Rotate transformations
T = phalanges{17}.local;
phalanges{17}.local = eye(4, 4);

Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

T = eye(4, 4);
T(1:D, 1:D) = Rx(-0.4) * Ry(2.7);
phalanges{2}.local = T * phalanges{2}.local;
phalanges{5}.local = T * phalanges{5}.local;
phalanges{8}.local = T * phalanges{8}.local;
phalanges{11}.local = T * phalanges{11}.local;
phalanges{14}.local = T * phalanges{14}.local;


%% Pose rotated model
theta = zeros(num_thetas, 1);
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
theta = zeros(num_thetas, 1);
phalanges = htrack_move(theta, dofs, phalanges);
[centers] = update_centers(centers, phalanges, names_map);

% figure; hold on; axis off; axis equal;
% display_skeleton(centers, radii, blocks(1:29), [], false, 'r');
% display_result(centers, [], [], blocks(1:29), radii, false, 1, 'big'); view([-180, -90]); camlight;
