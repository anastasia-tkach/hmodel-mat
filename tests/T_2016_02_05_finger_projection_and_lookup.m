close all;
clc;
clear;
D = 3;
rendering = true;

%% Hand model
input_path = '_my_hand/tracking_initialization/'; semantics_path = '_my_hand/semantics/';
load([semantics_path, 'tracking/names_map.mat']); load([semantics_path, 'tracking/named_blocks.mat']);
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']); load([semantics_path, 'fingers_blocks.mat']); palm_blocks = [palm_blocks, fingers_blocks{5}(4:7)]; 
load([semantics_path, 'fingers_base_centers.mat']);

%% Pose the model
% [attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
% [attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
% segments = initialize_ik_hmodel(centers, names_map);
% theta = randn(26, 1);
% [centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
% [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
% [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
% blocks = reindex(radii, blocks);
blocks([21:24, 35:37]) = [];

%% Rotate model
% rotation_axis = randn(D, 1);
% rotation_angle = 3 * randn;
% R = makehgtform('axisrotate', rotation_axis, rotation_angle);
% for i = 1:length(centers)
%     centers{i} = transform(centers{i}, R);
% end

%[centers, radii, blocks] = get_random_convsegment(D);
% [centers, radii, blocks] = get_random_convquad();
%[centers, radii, blocks] = get_random_convtriangle();

%% Generate data points
data_points = generate_depth_data_synthetic(centers, radii, blocks);
init_data_points = data_points;

i = randi([1, length(data_points)], 1);
camera_ray = [0; 0; 1];
camera_offset = -100;
camera_center = [0; 0; camera_offset];
initial_blocks = blocks;

%% Projections
data_points = init_data_points;
tangent_points = blocks_tangent_points(centers, blocks, radii);

verbose = false;
if verbose
    figure; hold on; axis off; axis equal;
    display_skeleton(centers, radii, blocks, [], false, []);
    mypoints(data_points, 'k');
end
model_indices = cell(length(data_points), 1);
model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
black_points = cell(length(data_points), 1);

%% Render the model
settings.fov = 15;
downscaling_factor = 2;
settings.W = 400/downscaling_factor;
settings.H = 700/downscaling_factor;
settings.D = D;
settings.side = 'front';
settings.view_axis = 'Z';
bounding_box = compute_model_bounding_box(centers, radii);
A = [(bounding_box.max_x - bounding_box.min_x) / (settings.W - 1), 0, bounding_box.min_x;
    0, (bounding_box.max_y - bounding_box.min_y) / (settings.H - 1), bounding_box.min_y;
    0, 0, 1];
raytracing_matrix = A;
[rendered_model, blocks_matrix] = render_orthographic_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
%figure; imshow(rendered_model(:, :, 3), []);

%% This side
raytraced_points = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    skeleton = cell(length(blocks), 1);
    indices = cell(length(blocks), 1);
    projections = cell(length(blocks), 1);
    insideness = cell(length(blocks), 1);
    other_indices = cell(length(blocks), 1);
    for j = 1:length(blocks)
        %if verbose, disp(blocks{j}); end
        %% Triangle
        if length(blocks{j}) == 3
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)}; c3 = centers{blocks{j}(3)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)}; r3 = radii{blocks{j}(3)};
            l = cross(c2 - c1, c3 - c1); l = l/norm(l);
            [~, ~, ~, insideness{j}] = projection_convtriangle(p, c1, c2, c3, r1, r2, r3, tangent_points{j}.v1, tangent_points{j}.v2, tangent_points{j}.v3, tangent_points{j}.u1, tangent_points{j}.u2, tangent_points{j}.u3, 0, 0, 0);
            if camera_ray' * tangent_points{j}.n < 0
                n = tangent_points{j}.n;
                v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
            else
                n = tangent_points{j}.m;
                v1 = tangent_points{j}.u1; v2 = tangent_points{j}.u2; v3 = tangent_points{j}.u3;
                tangent_points{j}.v1 = v1; tangent_points{j}.v2 = v2; tangent_points{j}.v3 = v3;
            end
            if l' * n < 0, l = -l; end
            cos_alpha = l' * n;
            
            distance = (p - c1)' * l;
            distance = distance / cos_alpha;
            s = p - n * distance;
            
            if is_point_in_triangle(s, c1, c2, c3)
                skeleton{j} = s;
                indices{j} = blocks{j};
                projections{j} = project_point_on_triangle(p, v1, v2, v3);
                if verbose
                    scatter3(skeleton{j}(1), skeleton{j}(2), skeleton{j}(3), 50, 'm', 'o', 'filled');
                end
            end
            
            if ~isempty(projections{j}), continue; end
            
            %% Segments
            [q12, s12, index12] = project_skewed_point_on_segment(p, c1, c2, r1, r2, blocks{j}(1), blocks{j}(2));
            [q13, s13, index13] = project_skewed_point_on_segment(p, c1, c3, r1, r3, blocks{j}(1), blocks{j}(3));
            [q23, s23, index23] = project_skewed_point_on_segment(p, c2, c3, r2, r3, blocks{j}(2), blocks{j}(3));
            
            d12 = norm(p - s12); d13 = norm(p - s13); d23 = norm(p - s23);
            s = {s12, s13, s23};
            q = {q12, q13, q23};
            index = {index12, index13, index23};
            [~, k] = min([d12, d13, d23]);
            skeleton{j} = s{k};
            indices{j} = index{k};
            projections{j} = q{k};
            if verbose
                scatter3(skeleton{j}(1), skeleton{j}(2), skeleton{j}(3), 50, 'c', 'o', 'filled');
            end
        end
        if length(blocks{j}) == 2
            c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
            r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
            [q, s, index] = project_skewed_point_on_segment(p, c1, c2, r1, r2, blocks{j}(1), blocks{j}(2));
            skeleton{j} = s;
            indices{j} = index;
            projections{j} = q;
            if verbose
                scatter3(skeleton{j}(1), skeleton{j}(2), skeleton{j}(3), 50, 'c', 'o', 'filled');
            end
        end
        
    end
    
    min_distance = inf;
    %% Find the answer
    for j = 1:length(indices)
        distance = compute_signed_distance(p, projections{j}, skeleton{j}, insideness{j});
        if length(indices{j}) == 3
            if verbose
                myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
                myline(centers{indices{j}(1)}, centers{indices{j}(3)}, 'r');
                myline(centers{indices{j}(2)}, centers{indices{j}(3)}, 'r');
            end
        end
        if length(indices{j}) == 2
            is_closest = true;
            for k = 1:length(blocks)
                if all(ismember(indices{j}, blocks{k}))
                    if ~all(ismember(indices{k}, indices{j}))
                        is_closest = false;
                    end
                end
            end
            if is_closest == false, continue; end
            if verbose
                if length(indices{j}) == 2, myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
                else scatter3(centers{indices{j}(1)}(1), centers{indices{j}(1)}(2), centers{indices{j}(1)}(3), 50, 'r', 'o', 'filled'); end
            end
        end
        %% Discard correspondence if inside of two primitives
        if distance < 0 && min_distance < 0
            other_indices{j}{end + 1} = blocks{j};
            model_points{i} = [];
            axis_points{i} = [];
        end
        %% Find min distance
        if distance < min_distance
            model_indices{i} = indices{j};
            model_points{i} = projections{j};
            axis_points{i} = skeleton{j};           
            min_distance = distance;
        end
    end
    
    if verbose
        scatter3(axis_points{i}(1), axis_points{i}(2), axis_points{i}(3), 50, 'k', 'o', 'filled');
        scatter3(p(1), p(2), p(3), 50, 'm', 'o', 'filled');
        myline(p, axis_points{i}, 'k');
    end
    
    %% Deal with backfacing by closest triangles
    if ~ rendering
        if isempty(model_points{i}), continue; end
        if camera_ray' * (model_points{i} - axis_points{i}) / norm(model_points{i} - axis_points{i}) > 0
            min_distance = inf;
            model_points{i} = [inf; inf; inf];
            for k = 1:length(blocks)
                if length(blocks{k}) == 2, continue; end
                if all(ismember(model_indices{i}, blocks{k}))
                    v1 = tangent_points{k}.v1; v2 = tangent_points{k}.v2; v3 = tangent_points{k}.v3;
                    q = project_point_on_triangle(p, v1, v2, v3);
                    distance = norm(p - q);
                    if distance < min_distance
                        min_distance = distance;
                        model_points{i} = q;
                        model_indices{i} =  blocks{k};
                    end
                end
            end
        end
    end
    
    %% Deal with backfacing and inside points by rendering
    if rendering        
        if isempty(model_points{i}) || camera_ray' * (model_points{i} - axis_points{i}) / norm(model_points{i} - axis_points{i}) > 0
            model_points{i} = [];
            x = p(1) - bounding_box.min_x;
            x = x / (bounding_box.max_x - bounding_box.min_x);
            x = x * (settings.W - 1);
            x  = min(max(x, 1), settings.W);
            y = p(2) - bounding_box.min_y;
            y = y / (bounding_box.max_y - bounding_box.min_y);
            y = y * (settings.H - 1);
            y  = min(max(y, 1), settings.H);
            q = p;
            q(3) = rendered_model(round(y), round(x), 3);
            
            b = abs(block_from_hash(blocks_matrix(round(y), round(x))));
            if any(ismember(model_indices{i}, b))
                model_points{i} = q;
                raytraced_points{i} = q;
                continue;
            end
            for k = 1:length(other_indices{j})
                if all(ismember(other_indices{j}{k}, b))
                    model_points{i} = q;
                    raytraced_points{i} = q;
                    continue;
                end
            end
            is_palm_blocks = false;
            for j = 1:length(palm_blocks)
                if all(ismember(model_indices{i}, palm_blocks{j}))
                    is_palm_blocks = true; break;
                end;
                for k = 1:length(other_indices{j})
                    if all(ismember(other_indices{j}{k}, b))
                        is_palm_blocks = true; break;
                    end
                end
            end;
            if ~is_palm_blocks, continue; end
            is_palm_blocks = false;
            for j = 1:length(palm_blocks), if all(ismember(b, palm_blocks{j})), is_palm_blocks = true; break; end; end;
            if ~is_palm_blocks, continue; end
            model_points{i} = q;
            raytraced_points{i} = q;
        end
    end
end

%% Find outline
outline2D = find_planar_outline(centers, blocks, radii, false);
[outline] = find_3D_outline(centers, outline2D);
[outline_indices, outline_points] = ...
    compute_projections_outline(data_points, outline, centers, radii, camera_ray);

%% Compare the distance to outline and distance to model
if ~rendering
    for i = 1:length(data_points)
        if isempty(model_points{i}), continue; end
        if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
            model_points{i} = outline_points{i};
            model_indices{i} = outline_indices{i};
        end
    end
end
if rendering
    for i = 1:length(data_points)
        if isempty(model_points{i}) || model_points{i}(3) == -32767
            model_points{i} = outline_points{i};
            raytraced_points{i} = [];
        end
    end
end

%% Display
display_result(centers, data_points, model_points, blocks, radii, false, 0.6, 'big');
data_color = [0, 0, 1];
model_color = 'r';
mypoints(data_points, data_color);
mypoints(model_points, model_color);
mylines(data_points, model_points, [0.8, 0.8, 0.8]);
mypoints(raytraced_points, 'r');
for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'y');
    else
        draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.start, outline{i}.end, 'y');
    end
end
view([-180, -90]); camlight;

%% Brute-force projections
% [brute_force_points] = compute_brute_force_projections(centers, radii, blocks, data_points);
% mypoints(brute_force_points, 'y');
% mylines(brute_force_points, data_points, 'r')




