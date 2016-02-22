clc;
clear;
D = 3;

%% Hand model
input_path = '_my_hand/tracking_initialization/'; semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']); load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
blocks = palm_blocks;
blocks = reindex(radii, blocks);

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

data_points = generate_depth_data_synthetic(centers, radii, blocks);
init_data_points = data_points;

%i = randi([1, length(data_points)], 1);
camera_ray = [0; 0; 1];

%% Projections
data_points = init_data_points;%(i);
tangent_points = blocks_tangent_points(centers, blocks, radii);

b = 8;
verbose = true;
if verbose
    figure; hold on; axis off; axis equal;
    display_skeleton(centers, radii, blocks, [], false, []);
    mypoints(data_points, 'k');
end
model_indices = cell(length(data_points), 1);
model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
black_points = cell(length(data_points), 1);

%% This side
for i = 1:length(data_points)
    p = data_points{i};
    skeleton = cell(length(blocks), 1);
    indices = cell(length(blocks), 1);
    projections = cell(length(blocks), 1);
    for j = 1:length(blocks)
        %if verbose, disp(blocks{j}); end
        %% Triangle
        c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)}; c3 = centers{blocks{j}(3)};
        r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)}; r3 = radii{blocks{j}(3)};
        l = cross(c2 - c1, c3 - c1); l = l/norm(l);
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
            mypoint(skeleton{j}, 'm');
            scatter3(skeleton{j}(1), skeleton{j}(2), skeleton{j}(3), 50, 'm', 'o', 'filled');
        end
        
    end
    
    %% Find the answer
    for j = 1:length(indices)
        if length(indices{j}) == 3
            if verbose
                myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
                myline(centers{indices{j}(1)}, centers{indices{j}(3)}, 'r');
                myline(centers{indices{j}(2)}, centers{indices{j}(3)}, 'r');
            end
            model_indices{i} = indices{j};
            model_points{i} = projections{j}; 
            axis_points{i} = skeleton{j};
            continue
        end
        is_closest = true;
        for k = 1:length(blocks)
            if all(ismember(indices{j}, blocks{k}))
                if ~all(ismember(indices{k}, indices{j}))
                    is_closest = false;
                end
            end
        end
        if is_closest == true
            model_indices{i} = indices{j};
            model_points{i} = projections{j};
            axis_points{i} = skeleton{j};
            if verbose
                if length(indices{j}) == 2
                    myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'g');
                else
                    scatter3(centers{indices{j}(1)}(1), centers{indices{j}(1)}(2), centers{indices{j}(1)}(3), 50, 'r', 'o', 'filled');
                end
            end
        end
    end
    
    %% Check the normal
    if camera_ray' * (model_points{i} - axis_points{i}) / norm(model_points{i} - axis_points{i}) > 0
        min_distance = [inf; inf; inf];
        for k = 1:length(blocks)
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

%% Find outline
outline2D = find_planar_outline(centers, blocks, radii, false);
[outline] = find_3D_outline(centers, outline2D);

%% Project on outline
[outline_indices, outline_points] = ...
    compute_projections_outline(data_points, outline, centers, radii, camera_ray);

%% Compare the distance to outline to second-best distance
for i = 1:length(data_points)
    if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
        model_points{i} = outline_points{i};
        model_indices{i} = outline_indices{i};
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
view([-180, -90]); camlight;

%{
%% Other side
if verbose
    figure; hold on; axis off; axis equal;
    display_skeleton(centers, radii, blocks, [], false, []);
    mypoints(data_points, 'k');
end
model_indices2 = cell(length(data_points), 1);
model_points2 = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    skeleton = cell(length(blocks), 1);
    indices = cell(length(blocks), 1);
    projections = cell(length(blocks), 1);
    for j = 1:length(blocks)
        if verbose, disp(blocks{j}); end
        %% Triangle
        c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)}; c3 = centers{blocks{j}(3)};
        r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)}; r3 = radii{blocks{j}(3)};
        l = cross(c2 - c1, c3 - c1); l = l/norm(l);
        if camera_ray' * tangent_points{j}.n > 0
            n = tangent_points{j}.n;
            v1 = tangent_points{j}.v1; v2 = tangent_points{j}.v2; v3 = tangent_points{j}.v3;
        else
            n = tangent_points{j}.m;
            v1 = tangent_points{j}.u1; v2 = tangent_points{j}.u2; v3 = tangent_points{j}.u3;
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
            mypoint(skeleton{j}, 'm');
            scatter3(skeleton{j}(1), skeleton{j}(2), skeleton{j}(3), 50, 'm', 'o', 'filled');
        end
        
    end
    
    %% Find the answer
    for j = 1:length(indices)
        if length(indices{j}) == 3
            if verbose
                myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
                myline(centers{indices{j}(1)}, centers{indices{j}(3)}, 'r');
                myline(centers{indices{j}(2)}, centers{indices{j}(3)}, 'r');
            end
            model_indices2{i} = indices{j};
            model_points2{i} = projections{j};      
            continue
        end
        is_closest = true;
        for k = 1:length(blocks)
            if all(ismember(indices{j}, blocks{k}))
                if ~all(ismember(indices{k}, indices{j}))
                    is_closest = false;
                end
            end
        end
        if is_closest == true
            model_indices2{i} = indices{j};
            model_points2{i} = projections{j};
            if verbose
                if length(indices{j}) == 2
                    myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'g');
                else
                    scatter3(centers{indices{j}(1)}(1), centers{indices{j}(1)}(2), centers{indices{j}(1)}(3), 50, 'r', 'o', 'filled');
                end
            end
        end
    end
end

for i = 1:length(data_points)
    if norm(data_points{i} - model_points{i}) > norm(data_points{i} - model_points2{i})
        model_points{i} = model_points2{i};
        model_indices{i} = model_indices2{i};
    end
end
%}

% %% Display
% display_result(centers, data_points, model_points, blocks, radii, true, 0.7, 'big');
% mypoints(model_points, 'y');
% mypoints(black_points, 'k');
% mylines(black_points, model_points, 'k');
% view([-180, -90]); camlight;

% [indices, model_points]  = projection_palm_skeleton(centers, radii, blocks, data_points, camera_ray);


%% Brute-force projections
% [brute_force_points] = compute_brute_force_projections(centers, radii, blocks, data_points);
% mypoints(brute_force_points, 'y');
% mylines(brute_force_points, data_points, 'r')

view([-180, -90]); camlight;



