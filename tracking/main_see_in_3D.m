close all;
num_joints = 21;
num_entries = num_joints * 3;
num_thetas = 29;

tx = 640 / 4;
ty = 480 / 4;
fx = 287.26;
fy = 287.26;

path = 'C:/Users/tkach/Desktop/training/';

%% Read joint locations
fileID = fopen('C:/Users/tkach/Desktop/training/joint_locations.txt','r');
joint_locations = fscanf(fileID, '%f');
num_frames = joint_locations(1);
joint_locations = joint_locations(2:end);
joint_locations = reshape(joint_locations, [num_entries, num_frames]);

%% Read joint angles
fileID = fopen('C:/Users/tkach/Desktop/training/solutions.track','r');
joint_angles = fscanf(fileID, '%f');
num_frames = joint_angles(1);
joint_angles = joint_angles(2:end);
joint_angles = reshape(joint_angles, [num_thetas, num_frames]);
joint_angles = joint_angles([1:6, 10:29], :);

%% Show in XYZ
figure; axis off; axis equal; hold on;
for i = 1:num_frames
    filename = [path, sprintf('%3.7d', i-1), '.png'];
    D = imread(filename);
    
    filename = [path, 'mask_', sprintf('%3.7d', i), '.png'];
    M = imread(filename);
    D(M == 0) = 0;
    
    [U, V] = meshgrid(1:size(D, 2), 1:size(D, 1));
    UVD = zeros(size(D, 1), size(D, 2), 3);
    UVD(:, :, 1) = U;
    UVD(:, :, 2) = V;
    UVD(:, :, 3) = D;
    uvd = reshape(UVD, size(UVD, 1) * size(UVD, 2), 3)';
    I = convert_uvd_to_xyz(tx, ty, fx, fy, uvd);
    
    xyz = joint_locations(:, i);
    xyz = reshape(xyz, 3, num_joints);
    
    xlim([-120  100]); ylim([-50, 150]); zlim([250, 450]);
    hold on;
    scatter3(I(1, :), I(2, :), I(3, :), 1, [0, 0.8, 0.9], 'filled');
    %scatter3(xyz(1, :), xyz(2, :), xyz(3, :), 20, 'm', 'filled');
    
    segments = create_ik_model('hand');
    [segments, joints] = pose_ik_model(segments, joint_angles(:, i), true, 'hand');
    %[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
    %display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
    
    drawnow; clf; axis off; axis equal;
end
%close all;