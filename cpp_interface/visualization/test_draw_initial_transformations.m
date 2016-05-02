clc; clear; close all;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

path = 'C:\Developer\data\MATLAB\transformations\';
[centers, radii, blocks, theta, phalanges, mean_centers] = read_cpp_model(path);

display_result(centers, [], [], blocks, radii, false, 0.87, 'big');
edge_color = [0, 0, 1];
view([-180, -90]); camlight;

x = [1; 0; 0];
y = [0; 1; 0];
z = [0; 0; 1];

line_width = 1;
factor = 6;
axis_color = [62, 127, 130]/300;
for i = 2:16%[2, 5, 8, 11, 14]
    R = phalanges{i}.local(1:3, 1:3)';
    
    X = R * x;
    Y = R * y;
    Z = R * z;    
    
    c = centers{names_map(phalanges{i}.name)};
    myvector(c, X, factor, axis_color, line_width);
    myvector(c, Y, factor, axis_color, line_width);
    myvector(c, Z, factor, axis_color, line_width);
end



