
close all; clear;

num_blocks = 1;

n = 70;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xy_background = zeros(n, n);
zy_background = zeros(n, n);

%% Display the projections
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[X_xy, Y_xy] = meshgrid(xm, ym);
[Z_zy, Y_zy] = meshgrid(zm, ym);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(1, 2, 1);
contourf(X_xy, Y_xy, xy_background, 200, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);

subplot(1, 2, 2);
contourf(Z_zy, Y_zy, zy_background', 200, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]);

%% Draw the model
[centers, blocks, radii] = draw_convtriangles_model(num_blocks, 0, 1);

save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\centers.mat'], 'centers');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\blocks.mat'], 'blocks');

%% Generate the data
points = generate_convtriangles_points(centers, blocks, radii);

%% Show 3D model
[blocks] = reindex(radii, blocks);
pose.centers = centers;
pose.num_centers = length(centers);
display_result_convtriangles(pose, blocks, radii, false);

%% Compute projections
[xy_distances, yz_distances] = silhouette_convtriangles(pose, blocks, radii, n);
model_bounding_box = compute_model_bounding_box(centers, radii);


%% Display the projections
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[X_xy, Y_xy] = meshgrid(xm, ym);
[Z_zy, Y_zy] = meshgrid(zm, ym);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(1, 2, 1);
contourf(X_xy, Y_xy, xy_distances, 1000, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]); axis off;
hold on; axis equal; xlim([model_bounding_box.min_x, model_bounding_box.max_x]);
ylim([model_bounding_box.min_y, model_bounding_box.max_y]);

subplot(1, 2, 2);
contourf(Z_zy, Y_zy, yz_distances', 1000, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]); axis off;
hold on; axis equal; xlim([model_bounding_box.min_z, model_bounding_box.max_z]);
ylim([model_bounding_box.min_y, model_bounding_box.max_y]);

[centers, blocks, radii] = draw_convtriangles_model(num_blocks, model_bounding_box.min_z, model_bounding_box.max_z);

%% Save the results

save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\1_points.mat'], 'points');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\1_centers.mat'], 'centers');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\blocks.mat'], 'blocks');














