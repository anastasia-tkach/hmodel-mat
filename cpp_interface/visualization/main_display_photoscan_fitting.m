clear; clc; close all;

D = 3;
num_poses = 4;
start_pose = 1;

semantics_path = '_my_hand/semantics/';
input_path = '_my_hand/fitting_initialization/';
output_path = 'C:/Developer/data/MATLAB/photoscan_fitting/';
optimization_path = 'C:/Developer/data/MATLAB/photoscan_fitting/optimization/';

load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat']);

poses = cell(num_poses, 1);
for k = start_pose:start_pose + num_poses - 1
    p = k - start_pose + 1;
    load([input_path, num2str(k), '_points.mat']); poses{p}.points = points;
    load([input_path, num2str(k), '_centers.mat']); poses{p}.centers = centers;
    num_centers = length(centers);
end

scales = [0.95, 0.96, 0.98, 1];
for p = 1:length(poses)
    T = scales(p) * eye(3, 3);
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = T * poses{p}.centers{i};
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = T * poses{p}.points{i};
    end
end

for p = 1:length(poses)
    shift = poses{p}.centers{names_map('palm_back')};
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - shift;
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.points{i} - shift;
    end
end

blocks{15} = [28; 19; 34];
blocks{27} = [28; 25; 34];

%% Rotate

p = 4;

Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];
if p == 1
    alpha = 0;
    beta = pi;
    gamma = 0;
end
if p == 2
    alpha = 0;
    beta = pi;
    gamma = 0;
end
if p == 3
    alpha = 0;
    beta = 0;
    gamma = 0;
end
if p == 4
    alpha = 0;
    beta = pi;
    gamma = 0;
end
R = Rx(alpha) * Ry(beta) * Rz(gamma);

xlimit = [-4; 4];
ylimit = [-3; 5];
zlimit = [-5; 5];
view_vector = [-180, -90];
if p == 3, view_vector = [0, 0]; end


%% Load
iter = 1;
count = 1;
load([optimization_path, 'X', num2str(1)]);
[poses, radii, blocks] = parse_argument(X, poses, cell(num_centers, 1), blocks);
load([optimization_path, 'X', num2str(2)]);
[adjusted_poses, adjusted_radii, adjusted_blocks] = parse_argument(X, poses, radii, blocks);

num_frames = 10;
radii_coefficient = linspace(1, 1.07, num_frames);
d1 = 1;
d2 = 7;
n = num_frames - 1;
y = zeros(num_frames, 1);
centers = poses{p}.centers;
adjusted_centers = adjusted_poses{p}.centers;

intermediate_centers = cell(length(centers), 1);
intermediate_radii = cell(length(centers), 1);
for i = 1:num_frames
    for o = 1:length(centers)
        d1 = centers{o};
        d2 = adjusted_centers{o};
        intermediate_centers{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
        
        d1 = radii{o};
        d2 = adjusted_radii{o};
        intermediate_radii{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
    end
    for o = [1:2, 5:6, 9:10, 13:14]
        intermediate_radii{o} = radii_coefficient(i) * intermediate_radii{o};
    end
    [centers_, points_] = rotate_model(intermediate_centers, poses{p}.points, R);
    display_result(centers_, [], [], blocks, intermediate_radii, false, 1, 'big');
    mypoints(points_, [179, 81, 109]/255, 1);
    view(view_vector);
    if p ~= 3, camlight; end
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    drawnow;
    print([output_path, 'fitting', num2str(count)],'-dpng', '-r300'); count = count + 1;
end

%% Next iterations
for iter = 3:6
    
    load([optimization_path, 'X', num2str(iter)]);
    [poses, radii, blocks] = parse_argument(X, poses, cell(num_centers, 1), blocks);
    
    %% Fix the wrist
    poses{p}.centers{names_map('wrist_bottom_left')} = adjusted_poses{p}.centers{names_map('wrist_bottom_left')};
    poses{p}.centers{names_map('wrist_bottom_right')} = adjusted_poses{p}.centers{names_map('wrist_bottom_right')};
    radii{names_map('wrist_bottom_left')} = adjusted_radii{names_map('wrist_bottom_left')};
    radii{names_map('wrist_bottom_right')} = adjusted_radii{names_map('wrist_bottom_right')};
    
    %% Adjust centers
    if p == 1
        poses{p}.centers{names_map('ring_base')} = poses{p}.centers{names_map('ring_base')} - 0.08 * [0; 0; 1];
        
        poses{p}.centers{names_map('ring_base')} = poses{p}.centers{names_map('ring_base')} - 0.07 * [0; 0; 1];
        poses{p}.centers{names_map('pinky_base')} = poses{p}.centers{names_map('pinky_base')} - 0.05 * [0; 0; 1] + 0.05 * [0; 1; 0];
    end
    if p == 3
        poses{p}.centers{names_map('index_base')} = poses{p}.centers{names_map('index_base')} - 0.1 * [1; 0; 0] + 0.05 * [0; 0; 1];
        poses{p}.centers{names_map('middle_base')} = poses{p}.centers{names_map('middle_base')} + 0.1 * [0; 0; 1] + 0.05 * [0; 1; 0];
        poses{p}.centers{names_map('ring_base')} = poses{p}.centers{names_map('ring_base')} + 0.1 * [0; 0; 1] - 0.05 * [0; 1; 0];
        poses{p}.centers{names_map('palm_back')} = poses{p}.centers{names_map('palm_back')} - 0.05 * [0; 0; 1] - 0.05 * [0; 1; 0];
    end
    if p == 4
        poses{p}.centers{names_map('index_base')} = poses{p}.centers{names_map('index_base')} - 0.05 * [0; 0; 1];
        poses{p}.centers{names_map('middle_base')} = poses{p}.centers{names_map('middle_base')} - 0.05 * [1; 0; 0] - 0.05 * [0; 0; 1];
        poses{p}.centers{names_map('ring_base')} = poses{p}.centers{names_map('ring_base')} - 0.1 * [0; 0; 1];
    end
    for i = [1:2, 5:6, 9:10, 13:14]
        radii{i} = 1.07 * radii{i};
    end
    
    %% Display
    [centers_, points_] = rotate_model(poses{p}.centers, poses{p}.points, R);
    display_result(centers_, [], [], blocks, radii, false, 1, 'big');
    mypoints(points_, [179, 81, 109]/255, 1);
    view(view_vector);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    if p ~= 3, camlight; end
    drawnow;
    
    %% Plot axis
    %{
    myvector(poses{p}.centers{names_map('palm_back')}, [1; 0; 0], 3, 'r');
    myvector(poses{p}.centers{names_map('palm_back')}, [0; 1; 0], 3, 'g');
    myvector(poses{p}.centers{names_map('palm_back')}, [0; 0; 1], 3, 'b');
    %}
    print([output_path, 'fitting', num2str(count)],'-dpng', '-r300'); count = count + 1;
    
end

%% Rotation
count = 1;
num_frames = 36;

centers = poses{p}.centers;
points = poses{p}.points;
rotated_centers = cell(length(centers), 1);
rotated_points = cell(length(points), 1);
alpha = linspace(0, 2 * pi, num_frames);
for i = 1:num_frames
    T = Ry(alpha(i));
    if p == 3, T = Rz(alpha(i)); end
    for o = 1:length(centers)
        rotated_centers{o} = T * centers{o};
    end
    for o = 1:length(points)
        rotated_points{o} = T * points{o};
    end
    
    [centers_, points_] = rotate_model(rotated_centers, rotated_points, R);
    display_result(centers_, [], [], blocks, radii, false, 1, 'big');
    mypoints(points_, [179, 81, 109]/255, 1);
    view(view_vector);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    if p ~= 3, camlight; end
    drawnow;
    print([output_path, 'rotation', num2str(count)],'-dpng', '-r300'); count = count + 1;
end
