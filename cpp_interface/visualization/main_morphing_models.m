clc; clear; %close all;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

template_name = 'thomas';
user_name = 'model';

xlimit = [-195.11, 185.43];
ylimit = [-60, 150];
zlimit = [-86.933, 50.376];

%% Load template model
input_path = ['C:\Developer\data\MATLAB\convolution_feel\', template_name, '\'];
[centers, radii, blocks, ~, mean_centers] = read_cpp_model(input_path);
[centers] = adjust_give_user(centers, template_name, names_map);
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
for o = 1:length(centers)
    centers{o} = Ry(2 * pi - 0.4) * centers{o};
end
template_centers = centers;
template_radii = radii;

%% Load morphed model
input_path = ['C:\Developer\data\MATLAB\convolution_feel\', user_name, '\'];
[centers, radii, blocks, ~, mean_centers] = read_cpp_model(input_path);
[centers] = adjust_give_user(centers, user_name, names_map);
for o = 1:length(centers)
    centers{o} = Ry(2 * pi - 0.4) * centers{o};
end


%{
display_result(centers, [], [], blocks, radii, false, 1, 'big');
view([-180, -90]);
xlim(xlimit); ylim(ylimit); zlim(zlimit);
camlight;
%}
%% Do the morphing
output_path = 'C:\Developer\data\MATLAB\convolution_feel\';
num_frames = 48;
y = zeros(num_frames, 1);
intermediate_centers = cell(length(centers), 1);
intermediate_radii = cell(length(centers), 1);
for i = 1:num_frames
    for o = 1:length(centers)
        d1 = template_centers{o};
        d2 = centers{o};
        intermediate_centers{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
        
        d1 = template_radii{o};
        d2 = radii{o};
        intermediate_radii{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
    end
    display_result(intermediate_centers, [], [], blocks, intermediate_radii, false, 1, 'big');
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; 
    drawnow;
    print([output_path, num2str(i)],'-dpng', '-r300');
end




