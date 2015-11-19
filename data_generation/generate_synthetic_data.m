
close all; clear;

num_blocks = 1;

n = 70;
min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;

%% Display the projections
figure('units','normalized','outerposition',[0 0 1 1])
subplot(1, 2, 1);
hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]);

subplot(1, 2, 2);
hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]);

%% Draw the model
[centers, blocks, radii] = draw_convtriangles_model(num_blocks, 0, 1);

% save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\centers.mat'], 'centers');
% save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\radii.mat'], 'radii');
% save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\blocks.mat'], 'blocks');

%% Generate the data
points = generate_convtriangles_points(centers, blocks, radii);

%% Find the normals
[indices, projections, ~] = compute_projections(points, centers, blocks, radii);
tangent_points = blocks_tangent_points(centers, blocks, radii);
normals = cell(length(points), 1);
tangent_point = [];
for i = 1:length(points)
    p = points{i};
    if length(indices{i}) == 1
        index = indices{i}(1);
        c1 = centers{index}; r1 = radii{index}; s = c1;
        q = c1 + r1 * (p - c1) / norm(p - c1);
    else
        if length(indices{i}) == 3
            for b = 1:length(blocks)
                if (length(blocks{b}) < 3), continue; end
                abs_index = [abs(indices{i}(1)), abs(indices{i}(2)), abs(indices{i}(3))];
                indicator = ismember(blocks{b}, abs_index);
                if sum(indicator) == 3
                    tangent_point = tangent_points{b};
                    break;
                end
            end
            indices{i} = abs_index;
        end
        [~, q, s, ~] = projection(p, indices{i}, radii, centers, tangent_point);
    end    
    normals{i} = (q - s) / norm(q - s);
end

%% Show 3D model
[blocks] = reindex(radii, blocks);
display_result_convtriangles(centers, [], [], blocks, radii, false);

%% Compute projections
[xy_distances, yz_distances] = silhouette_convtriangles(centers, blocks, radii, n);
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

[centers, blocks] = draw_tracking_model(num_blocks, radii, model_bounding_box.min_z, model_bounding_box.max_z);
%[centers, blocks, radii] = draw_convtriangles_model(num_blocks, model_bounding_box.min_z, model_bounding_box.max_z);

%% Save the results

solids = [];
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\1_points.mat'], 'points');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\1_normals.mat'], 'normals');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\1_centers.mat'], 'centers');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\radii.mat'], 'radii');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\blocks.mat'], 'blocks');
save(['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\convtriangles\solids.mat'], 'solids');














