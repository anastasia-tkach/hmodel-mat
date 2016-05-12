clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
output_path = 'C:\Developer\data\MATLAB\convolution_feel\';

surface_color = [61, 131, 119]/150;
spheres_color = surface_color;
%% Pill
%[centers, radii, blocks] = get_random_convsegment(3);
blocks = {[1, 2]};
centers{1} = [0.4; 0.0; 0.2];
centers{2} = [0.1; 0.3; 0.2];
radii{1} = 0.25;
radii{2} = 0.15;
xlimit = [-0.6486    0.7487]; 
ylimit = [-0.4001    0.2999];
zlimit = [-0.4    0.4];
shift = 0.5 * (centers{1} + centers{2});
centers{1} = centers{1} - shift;
centers{2} = centers{2} - shift;

%% Wedge
%{
blocks = {[1, 2, 3]};
radii{1} = 0.3;
radii{2} = 0.23;
radii{3} = 0.15;
centers{1} = [0.2518; 0.2904; 0.6171];
centers{2} = [0.2653; 0.8244; 0.9827];
centers{3} = [0.7302; 0.3439; 1.2];
xlimit = [-1.5    1.5]; 
ylimit = [-1    1];
zlimit = [-1.5   1.5];
shift = (centers{1} + centers{2} + centers{3}) / 3;
centers{1} = centers{1} - shift;
centers{2} = centers{2} - shift;
centers{3} = centers{3} - shift;
%}
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
iter = 0;
rotated_centers = cell(length(centers), 1);

%{
display_result(centers, [], [], blocks, radii, false, 1, 'big', surface_color);
view([-180, -90]);
camlight;
return;
%}

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
        draw_sphere(rotated_centers{o}, radii{o}, spheres_color, transparency(i));
    end
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300');
end

alpha = linspace(0, 2 * pi, num_frames);
transparency = linspace(0, 1, num_frames);
red_channel = linspace(spheres_color(1), surface_color(1), num_frames);
green_channel = linspace(spheres_color(2), surface_color(2), num_frames);
blue_channel = linspace(spheres_color(3), surface_color(3), num_frames);
for i = 1:num_frames - 1
    count = count + 1;
    for o = 1:length(centers)
        rotated_centers{o} = Ry(alpha(i)) * centers{o};
    end
    display_result(rotated_centers, [], [], blocks, radii, false, transparency(i), 'big', surface_color);
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
    display_result(rotated_centers, [], [], blocks, radii, false, 1, 'big', surface_color);
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300');
end
