%clc; clear; close all;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
num_thetas = 29;
theta = [0 0 0 0 0 0 0 0 0 -0.49 1.16 0.31 0.24 -0.13 -0.21 -0.31, 0.26 0.03 -0.17 -0.45 0.26 0.21 -0.29 -0.13 0.27 0.41 -0.26 0.10 0.051]/1.5;
%theta = zeros(num_thetas, 1);
[~, dofs] = hmodel_parameters();
xlimit = [-195.11       185.43];
ylimit = [-80        180];
zlimit = [ -100      65];

%% Template model
input_path = 'C:/Developer/data/models/template/';
[centers, radii, blocks, ~, phalanges, ~] = read_cpp_model(input_path);
wrist_scaling = 0.7;
centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_top_left')} + ...
    wrist_scaling * (centers{names_map('wrist_bottom_left')} - centers{names_map('wrist_top_left')});
centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_top_right')} + ...
    wrist_scaling * (centers{names_map('wrist_bottom_right')} - centers{names_map('wrist_top_right')});


phalanges = htrack_move(zeros(num_thetas, 1), dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);
centers{names_map('thumb_fold')} = centers{names_map('thumb_bottom')} + 0.01 * rand;

% display_result(centers, [], [], blocks, radii, false, 1, 'big');
% view([-180, -90]);
% %xlim(xlimit); ylim(ylimit); zlim(zlimit);
% camlight; drawnow;

%% Adjusted model
input_path = 'C:/Developer/data/models/anonymous/';
[adjusted_centers, adjusted_radii, blocks, ~, phalanges, ~] = read_cpp_model(input_path);

phalanges = htrack_move(zeros(num_thetas, 1), dofs, phalanges);
phalanges = initialize_offsets(adjusted_centers, phalanges, names_map);
phalanges = htrack_move(theta, dofs, phalanges);
adjusted_centers = update_centers(adjusted_centers, phalanges, names_map);
adjusted_centers{names_map('thumb_fold')} = adjusted_centers{names_map('thumb_bottom')} + 0.01 * rand;

%% Interpolation
output_path = 'C:\Developer\data\MATLAB\convolution_feel\';
num_frames = 3;
y = zeros(num_frames, 1);
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
    display_result(intermediate_centers, [], [], blocks, intermediate_radii, false, 1, 'big');
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; 
    drawnow;
    print([output_path, num2str(i)],'-dpng', '-r300');
end

