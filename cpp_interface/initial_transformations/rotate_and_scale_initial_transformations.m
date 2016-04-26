function [centers, radii, phalanges] = rotate_and_scale_initial_transformations(centers, radii, blocks, phalanges, dofs, theta, scaling_factor, names_map)

D = 3;
num_thetas = 29;
num_phalanges = 17;

%% Rotate centers 
for i = 1:length(phalanges)
    phalanges{i}.local = phalanges{i}.init_local;
end
phalanges = htrack_move(theta, dofs, phalanges);

[centers] = update_centers(centers, phalanges, names_map);

%% Rotate transformations
T = phalanges{18}.local;
phalanges{18}.local = eye(4, 4);

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

phalanges{17}.local = T * phalanges{17}.local;

%% Pose rotated model
theta = zeros(num_thetas, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 0.94;
phalanges{3}.local(2, 4) = 32;
phalanges{4}.local(2, 4) = 24.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
%disp('modified thumb top');
%phalanges{4}.offsets{1} = 1.3 * phalanges{4}.offsets{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = phalanges{4}.offsets{2} / norm( phalanges{4}.offsets{2});
%v = [ -0.1650; 0.9841; 0.0658];
v = [ -0.05; 0.9841; 0.13];
v = v/norm(v);
phalanges{4}.offsets{2} = 18 * v;
phalanges{4}.offsets{1} = 0.95 * phalanges{4}.offsets{1};
phalanges{7}.offsets{1} = f * phalanges{7}.offsets{1};
phalanges{10}.offsets{1} = f * phalanges{10}.offsets{1};
phalanges{13}.offsets{1} = f * phalanges{13}.offsets{1};
phalanges{16}.offsets{1} = f * phalanges{16}.offsets{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theta = zeros(num_thetas, 1);
phalanges = htrack_move(theta, dofs, phalanges);
[centers] = update_centers(centers, phalanges, names_map);

%% Scale
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end

% figure; hold on; axis off; axis equal;
% display_skeleton(centers, radii, blocks(1:29), [], false, 'r');
% display_result(centers, [], [], blocks(1:29), radii, false, 1, 'big'); view([-180, -90]); camlight;
