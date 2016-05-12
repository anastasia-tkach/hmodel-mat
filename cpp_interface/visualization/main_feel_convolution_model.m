clc; clear; close all;

semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

input_path = 'C:\Developer\data\MATLAB\convolution_feel\model\';
output_path = 'C:\Developer\data\MATLAB\convolution_feel\';

[centers, radii, blocks, theta, mean_centers] = read_cpp_model(input_path);

shift = centers{26};
for i = 1:length(centers)
    centers{i} = centers{i} - shift;
end
wrist_scaling = 0.7;
centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_top_left')} + wrist_scaling * (centers{names_map('wrist_bottom_left')} - centers{names_map('wrist_top_left')});
centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_top_right')} + wrist_scaling * (centers{names_map('wrist_bottom_right')} - centers{names_map('wrist_top_right')});


Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
iter = 0;
rotated_centers = cell(length(centers), 1);

%{
display_result(centers, [], [], blocks, radii, false, 1, 'big');
view([-180, -90]);
xlim([-179.67       190.17]); ylim([-63.505       140]); zlim([-100      100]);
camlight;
return
%}

xlimit = [-195.11       185.43];
ylimit = [-60        150];
zlimit = [ -86.933       65];

%% Show spheres
num_frames = 48;
alpha = linspace(0, 2 * pi, num_frames);
transparency = linspace(0, 1, num_frames);
count = 0;
for i = 1:num_frames - 1
    count = count + 1;
    for o = 1:length(centers)
        rotated_centers{o} = Ry(alpha(i)) * centers{o};
    end
    display_result(rotated_centers, [], [], blocks, radii, false, 0, 'big');
    display_skeleton(rotated_centers, [], blocks, [], false, [61, 131, 119]/255);
    for o = 1:length(centers)
        draw_sphere(rotated_centers{o}, radii{o}, [144, 194, 171]/255, transparency(i));
    end
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300');
end

alpha = linspace(0, 2 * pi, num_frames);
transparency = linspace(0, 1, num_frames);
red_channel = linspace(144/255, 240/255, num_frames);
green_channel = linspace(194/255, 189/255, num_frames);
blue_channel = linspace(171/255, 157/255, num_frames);
for i = 1:num_frames - 1
    count = count + 1;
    for o = 1:length(centers)
        rotated_centers{o} = Ry(alpha(i)) * centers{o};
    end
    display_result(rotated_centers, [], [], blocks, radii, false, transparency(i), 'big');
    display_skeleton(rotated_centers, [], blocks, [], false, [61, 131, 119]/255);
    for o = 1:length(centers)
        draw_sphere(rotated_centers{o}, radii{o}, [red_channel(i), green_channel(i), blue_channel(i)], 1);
    end
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300');
end

for i = 1:num_frames
    count = count + 1;
    for o = 1:length(centers)
        rotated_centers{o} = Ry(alpha(i)) * centers{o};
    end
    display_result(rotated_centers, [], [], blocks, radii, false, 1, 'big');
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300');
end
