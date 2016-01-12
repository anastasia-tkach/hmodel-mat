function [beta, theta] = load_htrack_data(sensor_path, output_path, K, D)

num_joints = 21; num_entries = num_joints * D; num_thetas = 29;
fileID = fopen([sensor_path, 'solutions.track'], 'r');
joint_angles = fscanf(fileID, '%f');
num_frames = joint_angles(1); joint_angles = joint_angles(2:end);
joint_angles = reshape(joint_angles, [num_thetas, num_frames]);
joint_angles = joint_angles([1:6, 10:29], :); theta = joint_angles(:, K);

if ~exist([output_path, 'beta.mat'], 'file') 
    fileID = fopen([sensor_path, 'joint_locations.txt'], 'r');
    joint_locations = fscanf(fileID, '%f');
    num_frames = joint_locations(1); joint_locations = joint_locations(2:end);
    joint_locations = reshape(joint_locations, [num_entries, num_frames]);
    beta = joint_locations(:, K);
else
    load([output_path, 'beta.mat']);
end