num_blocks = 2;
n = 70;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;

figure('units','normalized','outerposition',[0 0 1 1])
subplot(1, 2, 1);
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);

subplot(1, 2, 2);
hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]); 
[centers, blocks, radii] = draw_convtriangles_model(num_blocks, 0, 1);


%% Draw datapoint

% subplot(1, 2, 1);
% [x, y, key] = ginput(1);
% p = [x; y];
% hold on; mypoint(p, 'm');
% 
% subplot(1, 2, 2)
% line([min_z, max_z], [y, y], 'color', [0, 0.5, 0.5], 'lineWidth', 2, 'lineStyle', '-.');
% [z, w] = ginput(1);
% p = [p; z];
% mypoint([z; w], 'm');


%% Show 3D model
[blocks] = reindex(radii, blocks);
pose.centers = centers;
pose.num_centers = length(centers);
display_result_convtriangles(pose, blocks, radii, false);
%hold on; mypoint(p, 'm');
%points  = cell(1, 1); points{1} = p;


%% Save the model and the point

%save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\points.mat'], 'points');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\centers.mat'], 'centers');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\blocks.mat'], 'blocks');

