close all; clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
load([path, 'radii2']);
load([path, 'centers2']);
load([path, 'blocks2']);

new_centers = centers;
new_radii = radii;
new_blocks = blocks;

% c4 = centers{4} + [-0.2033; -0.0682; -0.1011];
% r4 = radii{4};

load([path, 'radii1']);
load([path, 'centers1']);
load([path, 'blocks1']);

% new_centers = centers;
% new_radii = radii;
num_poses = 1;
num_centers = length(centers);
D = 3;
% for o = 1:num_centers
%     new_centers{o} = centers{o} + 0.001 * randn(D, 1);
%     new_radii{o} = radii{o} +  0.001 * randn(1, 1);
% end
% new_blocks = blocks;
% new_centers{4} = c4;
% new_radii{4} = r4;

delta = zeros(D * num_centers * num_poses + num_centers, 1);

for o = 1:num_centers
    delta(D * o - D + 1:D * o) = new_centers{o} - centers{o};
    delta(D * num_poses * num_centers + o) = new_radii{o} - radii{o};
end

pose.centers = centers;
display_result_convtriangles(pose, blocks, radii, false);
pose.centers = new_centers;
display_result_convtriangles(pose, blocks, new_radii, false);

pose.centers = centers;
poses{1} = pose;
[poses, radii] = apply_update(poses, blocks, radii, delta, D);
display_result_convtriangles(poses{1}, blocks, radii, false);