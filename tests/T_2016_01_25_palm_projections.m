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
blocks = palm_blocks;
blocks = reindex(radii, blocks);

data_points = generate_depth_data_synthetic(centers, radii, blocks);
init_data_points = data_points;

data_points = init_data_points;
camera_ray = [0; 0; 1];
camera_offset = -50;
camera_center = [0; 0; camera_offset];

%% Render palm
display_result(centers, [], [], blocks, radii, false, 0.5, 'big');

tangent_points = blocks_tangent_points(centers, blocks, radii);
model_bounding_box = compute_model_bounding_box(centers, radii);
num_samples = 30;
X = linspace(model_bounding_box.min_x, model_bounding_box.max_x, num_samples);
Y = linspace(model_bounding_box.min_y, model_bounding_box.max_y, num_samples);
rendered_points = {};
for i = 1:num_samples
    for j = 1:num_samples
        p = [X(i); Y(j); camera_offset];
        %myline(p, p + camera_ray * 100, 'g');
        rendered_points{end + 1} = ray_model_intersection(centers, blocks, radii, tangent_points, p, camera_ray);
    end
end

%% Display 

mypoints(rendered_points, 'k');
view([-180, -90]); camlight; drawnow;

return


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



