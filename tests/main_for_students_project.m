% centers1 = poses{1}.centers;
% centers2 = poses{2}.centers;
% save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_data\fingers\1_final_centers.mat', 'centers1');
% save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_data\fingers\2_final_centers.mat', 'centers2');
% save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_data\fingers\final_radii.mat', 'radii');

pose_id = 2;

absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\fingers\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

if (pose_id == 1)
    load([data_path, '1_points']);
    load([data_path, '1_final_centers']);
end
if (pose_id == 2)
    load([data_path, '2_points']);    
    load([data_path, '2_final_centers']);
end

n = 60; color = [0.2, 0.8, 0.8];
[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
P = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);

figure; hold on;
for i = 1:length(blocks)
    if length(blocks{i}) == 2
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, P');
    end
    distances = reshape(distances, size(x));
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 1);
    grid off; view([1,1,1]); axis equal; camlight; lighting gouraud; axis off;
end

%% Display data
k = 0;
P = zeros(length(points), 3);
for i = 1:length(points)
    k = k + 1;
    P(k, :) =  points{i}';
end
P = P(1:k, :);
scatter3(P(:, 1), P(:, 2), P(:, 3), 10, 'filled', 'o', 'm');




