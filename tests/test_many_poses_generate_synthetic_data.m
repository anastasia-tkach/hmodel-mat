set_path; close all; clear; num_blocks = 2; n = 70;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xy_background = zeros(n, n); zy_background = zeros(n, n);

% Display the projections
xm = linspace(min_x, max_x, n); ym = linspace(min_y, max_y, n); zm = linspace(min_z, max_z, n);
[X_xy, Y_xy] = meshgrid(xm, ym); [Z_zy, Y_zy] = meshgrid(zm, ym);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(1, 2, 1); contourf(X_xy, Y_xy, xy_background, 200, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);

subplot(1, 2, 2); contourf(Z_zy, Y_zy, zy_background', 200, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]);
[centers, blocks, radii] = draw_convtriangles_model(num_blocks, 0, 1);

%% Create many poses
[blocks] = reindex(radii, blocks);
true_centers = centers; true_radii = radii; true_blocks = blocks;
num_poses = 3; n = 70; alpha = pi/4; p = 1;
true_poses = cell(num_poses, 1);
true_poses{1}.centers = true_centers;
display_result_convtriangles(true_poses{p}, true_blocks, radii, false);
for p = 2:num_poses
    for i = 1:length(true_blocks)
        for j = i + 1:length(true_blocks)
            common = ismember(true_blocks{i}, true_blocks{j});
            common = true_blocks{i}(common);
            if (length(common) == 1)
                common = common(1);
                rotaxis = rand(3, 1);                
                for k = 1:length(true_blocks{j})
                    if (true_blocks{j}(k) == common), continue; end;
                    original = true_centers{true_blocks{j}(k)} - true_centers{common};
                    rotated = rotate_around_axis(rotaxis, original, alpha);
                    true_centers{true_blocks{j}(k)} = true_centers{common} + rotated * norm(original);
                end
            end
            if (length(common) == 2)
                index3 = ~ismember(true_blocks{j}, common);
                index3 = true_blocks{j}(index3);
                [~, t, ~] = point_to_segment_distance(true_centers{index3}, true_centers{common(1)}, true_centers{common(2)}, radii{common(1)}, radii{common(2)});
                rotaxis = true_centers{common(1)} - true_centers{common(2)};
                original = true_centers{index3} - t;
                rotated = rotate_around_axis(rotaxis, original, alpha);
                true_centers{index3} = t + rotated * norm(original);
            end
        end
    end
    true_poses{p}.centers = true_centers;
    display_result_convtriangles(true_poses{p}, true_blocks, radii, false);
end

poses = cell(num_poses, 1);
for p = 1:num_poses
    %% Generate the data
    points = generate_convtriangles_points(true_poses{p}.centers, true_blocks, true_radii);
    
    %% Show 3D model
    display_result_convtriangles(true_poses{p}, true_blocks, true_radii, false);
    
    %% Compute projections
    [xy_distances, yz_distances] = silhouette_convtriangles(true_poses{p}, true_blocks, true_radii, n);
    [min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(true_poses{p}.centers, true_radii);
    
    
    %% Display the projections
    xm = linspace(min_x, max_x, n);
    ym = linspace(min_y, max_y, n);
    zm = linspace(min_z, max_z, n);
    [X_xy, Y_xy] = meshgrid(xm, ym);
    [Z_zy, Y_zy] = meshgrid(zm, ym);
    
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1, 2, 1);
    contourf(X_xy, Y_xy, xy_distances, 200, 'edgeColor', 'none');
    colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
    hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);
    
    subplot(1, 2, 2);
    contourf(Z_zy, Y_zy, yz_distances', 200, 'edgeColor', 'none');
    colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
    hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]);
    
    [poses{p}.centers, blocks, radii] = draw_convtriangles_model(num_blocks, min_z, max_z);
    centers = poses{p}.centers;
    
    %% Save the results
    
    save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\', num2str(p), '_points.mat'], 'points');
    save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\',  num2str(p), '_centers.mat'], 'centers');
end
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convtriangles\blocks.mat'], 'blocks');
