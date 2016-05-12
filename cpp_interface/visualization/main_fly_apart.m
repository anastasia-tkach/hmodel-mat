clc; clear; %close all;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

user_name = 'model';
input_path = ['C:\Developer\data\MATLAB\convolution_feel\', user_name, '\'];
output_path = ['C:\Developer\data\MATLAB\convolution_feel\'];
[centers, radii, blocks, ~, mean_centers] = read_cpp_model(input_path);

shift = centers{26};
for i = 1:length(centers)
    centers{i} = centers{i} - shift;
end

wrist_scaling = 0.7;
centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_top_left')} + wrist_scaling * (centers{names_map('wrist_bottom_left')} - centers{names_map('wrist_top_left')});
centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_top_right')} + wrist_scaling * (centers{names_map('wrist_bottom_right')} - centers{names_map('wrist_top_right')});
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];

for o = 1:length(centers)
    centers{o} = Ry(2 * pi - 0.4) * centers{o};
end
%% Display

count = 0;
display_result(centers, [], [], blocks, radii, false, 1, 'big');
view([-180, -90]);
xlim([-195.11       185.43]); ylim([-60        150]); zlim([ -86.933       50.376]);
camlight; drawnow;
print([output_path, user_name, '_', num2str(count)],'-dpng', '-r300');

for i = 1:length(blocks)    
    count = count + 1;  
    display_result(centers, [], [], blocks(i), radii, false, 1, 'big', [217 + 179, 154 + 81, 143 + 109]/510);
    view([-180, -90]);
    xlim([-195.11       185.43]); ylim([-60        150]); zlim([ -86.933       50.376]);
    camlight; drawnow;
    print([output_path, user_name, '_', num2str(count)],'-dpng', '-r300');
end
