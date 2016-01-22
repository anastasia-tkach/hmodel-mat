close all;
clc;
D = 3;

%% Synthetic model
% [centers, radii, blocks] = get_random_convtriangle();
% [centers, radii, blocks] = get_random_convsegment(D);
% [centers, radii, blocks] = get_random_convquad();

%% Hand model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
blocks = palm_blocks;

data_points = generate_depth_data_synthetic(centers, radii, blocks);
%init_data_points = data_points;
%data_points = init_data_points(1:200);

camera_ray = [0; 0; 1];
camera_center = [0; 0; 0];

%% Compute projections and normals
display_result(centers, data_points, model_points, blocks, radii, false, 0.5, 'small');

[model_indices, model_points, block_indices, axis_projections, is_best_projection] = compute_projections_front(data_points, centers, blocks, radii, camera_ray);
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

%% Display
%display_result(centers, data_points, model_points, blocks, radii, true, 1, 'small');
data_color = [0.65, 0.1, 0.5];
model_color = [0, 0.7, 1];
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
