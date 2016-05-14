%clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
output_path = 'C:\Developer\data\MATLAB\convolution_feel\';

surface_color = [61, 131, 119]/150;
spheres_color = surface_color;
%% Pill
%{
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

d = (centers{1} - centers{2}) / norm(centers{1} - centers{2});
adjusted_centers{1} = centers{1} - 0.13 * d;
adjusted_centers{2} = centers{2} + 0.13 * d;

adjusted_radii{1} = radii{1} * 0.25;
adjusted_radii{2} = radii{2} * 1;

%}

%% Wedge
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


%% Adjusted centers
d2 = (centers{1} - centers{2}) / norm(centers{1} - centers{2});
d3 = (centers{1} - centers{3}) / norm(centers{1} - centers{3});
% adjusted_centers{1} = centers{1};
% adjusted_centers{2} = centers{2} + 0.45 * d2;
% adjusted_centers{3} = centers{3} - 0.25 * d3;

adjusted_radii{1} = radii{1} * 0.25;
adjusted_radii{2} = radii{2} * 1;
adjusted_radii{3} = radii{3} * 2;


%% Swap direction
% temp_centers = adjusted_centers;
% adjusted_centers = centers;
% centers = temp_centers;

temp_radii = adjusted_radii;
adjusted_radii = radii;
radii = temp_radii;

%{
display_result(centers, [], [], blocks, radii, false, 1, 'big', surface_color);
view([-180, -90]);
camlight;
return;
%}

count = 32;
num_frames = 32;
d1 = 1; 
d2 = 7;
n = num_frames - 1;
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
    blocks = reindex(intermediate_radii, blocks);
    display_result(intermediate_centers, [], [], blocks, intermediate_radii, false, 1, 'big', surface_color);
    view([-180, -90]);
    xlim(xlimit); ylim(ylimit); zlim(zlimit);
    camlight; 
    drawnow;
    print([output_path, num2str(count)],'-dpng', '-r300'); count = count + 1;
end
