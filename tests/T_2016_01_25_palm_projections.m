close all;
clc;
clear;
D = 3;
% Synthetic model
% [centers, radii, blocks] = get_random_convsegment(D);
% [centers, radii, blo5cks] = get_random_convquad();
% [centers, radii, blocks] = get_random_convtriangle();

% Hand model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
%blocks = palm_blocks;
blocks = reindex(radii, blocks);

data_points = generate_depth_data_synthetic(centers, radii, blocks);
init_data_points = data_points;

data_points = init_data_points;
camera_ray = [0; 0; 1];
camera_offset = -50;
camera_center = [0; 0; camera_offset];

%% Render palm

% tangent_points = blocks_tangent_points(centers, blocks, radii);
% rendered_points = {};
% 
% model_bounding_box = compute_model_bounding_box(centers, radii);
% H = 640; W = 480;
% R = linspace(model_bounding_box.min_x, model_bounding_box.max_x, H);
% C = linspace(model_bounding_box.min_y, model_bounding_box.max_y, W);
% I = cell(H, W);
% D = zeros(H, W);
% for i = 1:H
%     for j = 1:W
%         p = [R(i); C(j); camera_offset];
%         [~, ~, I{i, j}] = ray_model_intersection(centers, blocks, radii, tangent_points, p, camera_ray);
%     end
% end



%% Display
C = 50;
settings.fov = 15;
downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D;
settings.side = 'front';
settings.view_axis = 'Z';
data_bounding_box = compute_model_bounding_box(centers, radii);
[raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
[rendered_model, I] = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
figure; imshow(rendered_model(:, :, 3), []);

%% Visualize
M = zeros(settings.H, settings.W);
n = length(centers);
hash_to_index = containers.Map('KeyType','uint32', 'ValueType', 'uint32') ;
count = 0;
I = I + 1;
for i = 1:settings.H
    for j = 1:settings.W
        v = 0;
        w = I(i, j);
        if ~isKey(hash_to_index, abs(w))
            hash_to_index(abs(w)) = count;            
            M(i, j) = count;
            count = count + 1;
        else
             M(i, j) = hash_to_index(abs(w));
        end        
    end
end
M = flipud(M); 
figure; image(M, 'CDataMapping','scaled'); axis off; axis equal; colormap jet;

%display_result(centers, [], [], blocks, radii, false, 0.5, 'big');
%mypoints(rendered_points, 'k');
%mypoints(data_points, 'm');
%view([-180, -90]); camlight; drawnow;


return;
%% Project palm
[model_indices, model_points, axis_projections, is_best_projection]  = projection_palm(centers, radii, blocks, data_points, camera_ray, camera_center);
model_normals = compute_model_normals_temp(centers, blocks, radii, model_points, model_indices);
suboptimal_indices = [];
for i = 1:length(model_points)
    if isempty(model_points{i}), continue; end
    if any(isinf(model_points{i})) || ~is_best_projection(i)
        suboptimal_indices(end + 1) = i;
    end
end

%% Find outline
outline2D = find_planar_outline(centers, blocks, radii, false);
[outline] = find_3D_outline(centers, outline2D);

%% Project on outline
[outline_indices, outline_points] = ...
    compute_projections_outline(data_points(suboptimal_indices), outline, centers, radii, camera_ray);

%% Compare the distance to outline to second-best distance
for i = 1:length(suboptimal_indices)
    j = suboptimal_indices(i);
    if norm(data_points{j} - outline_points{i}) < norm(data_points{j} - model_points{j})
        model_points{j} = outline_points{i};
        model_indices{j} = outline_indices{i};
    end
end

%% Display transparent
display_result(centers, data_points, model_points, blocks, radii, true, 0.6, 'big');
data_color = [0.65, 0.1, 0.5];
model_color = [1, 1, 1];
mypoints(data_points, data_color);
mypoints(model_points, model_color);
mylines(data_points, model_points, [0.1, 0.8, 0.8]);
for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'y');
    else
        draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.start, outline{i}.end, 'y');
    end
end
view([-180, -90]); camlight; drawnow;



