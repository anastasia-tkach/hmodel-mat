input_path = 'E:/Data/msr_comparison/Sharp_2015/';
listing = dir(input_path);

numbers = zeros(length(listing) - 2, 1);
for i = 3:length(listing)  
    array = strsplit(listing(i).name, '-');
    numbers(i - 2) = str2num(array{1});
end

numbers = sort(numbers);

return
clc; clear; close all;
RAND_MAX = 32767;
background_value = 5000;
input_path = 'E:/Data/msr_comparison/';
height = 240;
width = 320;

figure_size = [0, 0, 1, 1];
figure('units', 'normalized', 'outerposition', figure_size); hold on; axis off; axis equal;
frame = 654;
for frame = 1:2859
    filename = [input_path, 'Depth/depth-', sprintf('%07d', frame), '.png']; D = imread(filename);
    filename = [input_path, 'Mask/mask-', sprintf('%07d', frame), '.png']; M = imread(filename);
    filename = [input_path, 'Tkach_2016/model-', sprintf('%07d', frame), '.png']; Q = imread(filename);
    %filename = [input_path, 'Taylor_2016/', num2str(frame), '-Rendered depth---image.png']; R = imread(filename);
    filename = [input_path, 'Sharp_2015/', num2str(frame), '-Rendered depth---image.png']; R = imread(filename);
    
    D(M == 0) = 0;
    iproj = [0.00348117, 0, -0.556987; 0, 0.00348117, -0.41774; 0, 0, 1];
    
    %% Sensor points
    data_points = {};
    for i = 1:height
        for j = 1:width
            if D(height - i + 1, j)  ~= 0
                depth = double(D(height - i + 1, j));
                uvd = [(j - 1) * depth; (i - 1) * depth; depth];
                data_points{end + 1} = iproj * uvd;
            end
        end
    end
    
    %% Our points
    model_points = {};
    for i = 1:height
        for j = 1:width
            if Q(height - i + 1, j)  < RAND_MAX
                depth = double(Q(height - i + 1, j));
                uvd = [(j - 1) * depth; (i - 1) * depth; depth];
                model_points{end + 1} = iproj * uvd;
            end
        end
    end
    
    %% Taylor points
    taylor_points = {};
    for i = 1:height
        for j = 1:width
            if R(height - i + 1, j)  < background_value
                depth = double(R(height - i + 1, j));
                uvd = [(j - 1) * depth; (i - 1) * depth; depth];
                taylor_points{end + 1} = iproj * uvd;
            end
        end
    end
    
    %% Read model
    clf;
    hold on; axis off; axis equal;
    %mypoints(model_points,  [0.0, 0.7, 1.0]);
    mypoints(data_points,  [0.7, 0.0, 0.3]);
    mypoints(taylor_points,  [0.0, 0.7, 0.3]);
    view([-180, -90]); camlight; drawnow; 
end



