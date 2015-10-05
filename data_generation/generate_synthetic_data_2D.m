
close all; clear;

num_blocks = 2;

n = 70;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xy_background = zeros(n, n);

%% Display the projections
figure('units','normalized','outerposition',[0 0 1 1])
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);

%% Draw the model
[centers, blocks, radii] = draw_convtriangles_model_2D(num_blocks);

%% Generate the data
num_points = 1;
points = cell(num_points, 1);
for i = 1:num_points
    [x, y] = ginput(1);
    points{i} = [x; y];
    mypoint(points{i}, 'b');
end


%% Save the results
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\1_points.mat'], 'points');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\1_centers.mat'], 'centers');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\blocks.mat'], 'blocks');














