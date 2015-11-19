% close all;
% clear
% D = 3; RAND_MAX = 32767;
% settings.fov = 15;
% downscaling_factor = 3;
% settings.H = 480/downscaling_factor;
% settings.W = 636/downscaling_factor;
% settings.D = D;
% settings.sparse_data = false;
% settings.RAND_MAX = 32767;
% settings.side = 'front';
% settings.view_axis = 'X';
% closing_radius = 10;
% mode = 'synthetic';
% 
% %% Generate data
% [centers, radii, blocks] = get_random_convtriangle();
% edge_indices = {{[1, 2], [1, 3], [2, 3]}};
% 
% % [centers, radii, blocks] = get_random_convsegment();
% % edge_indices = {{[1, 2]}};
% 
% data_bounding_box = compute_model_bounding_box(centers, radii);
% model_points  = [];
% [raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
% rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
% 
% [I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));
% N = length(model_points);
% model_points = [model_points; cell(length(I), 1)];
% for k = 1:length(I), model_points{N + k} = squeeze(rendered_model(I(k), J(k), :)); end
% points = model_points;
% 
% %% Generate model
% rotation_axis = randn(D, 1); rotation_angle = 0.2 * randn;
% translation_vector = 2 * randn(D, 1);
% R = makehgtform('axisrotate', rotation_axis, rotation_angle);
% T = makehgtform('translate', translation_vector);
% for i = 1:length(centers)
%     centers{i} = transform(centers{i}, R);
%     centers{i} = transform(centers{i}, T);
% end
% 
% data_bounding_box = compute_data_bounding_box(points);
% solid_blocks = {[1]};
% k = 1;
% for i = 1:length(blocks)
%     index = nchoosek(blocks{i}, 2);
%     for j = 1:size(index, 1)
%         restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
%         previous_rotations{k} = eye(3, 3);
%         k = k + 1;
%     end
% end
% attachments = cell(length(centers), 1);
% initial_centers = centers;

%% Algorithm
close all; centers = initial_centers;

for iter = 1:4
    
    %% Render model and data
    [raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings,  settings.side);
    [rendered_data, back_map_for_rendered_data, P] = render_tracking_data(points, camera_axis, camera_center, settings.view_axis, closing_radius, settings);
       
    rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
    
    [I, J] = find((rendered_model(:, :, 3) > - RAND_MAX) & (rendered_data == 0));
    model_points = cell(length(I), 1);
    for k = 1:length(I), model_points{k} = squeeze(rendered_model(I(k), J(k), :)); end
    
    [model_indices, model_projections, ~] = compute_projections(model_points, centers, blocks, radii);    

    [closest_data_points, ~, ~] = find_silhouette_constraints(model_points, back_map_for_rendered_data, rendered_data, P,  settings.view_axis);
     
    %% Display
    %rendered_intersection = zeros(size(rendered_model));
    %rendered_intersection(:, :, 3) = (rendered_model(:, :, 3) > -RAND_MAX);
    %rendered_intersection(:, :, 1) = rendered_data;
    %figure; imshow(rendered_intersection); hold on;
    %mypoints(model_points_2D, [0, 0.7, 1]);
    %mypoints(data_points_2D, [1, 0.7, 0.1]);
    
    display_result_convtriangles(centers, points, [], blocks, radii, true);
    %mypoints(model_points, [0, 0.7, 1]);
    %mypoints(closest_data_points, [0.4, 0, 0.4]);
    mypoints(points, [0.65, 0.1, 0.5]);
    view([-90, 0]); camlight; drawnow;
    
    if isempty(model_points), break; end
    
    %% Move behind the data silhouette
    [F, J] = jacobian_arap_translation_attachment(centers, radii, blocks, ...
        model_points, model_indices, closest_data_points, attachments, settings.D);
    
    normals = cell(length(model_points), 1);
    
    
    for i = 1:length(model_points)
        m = model_points{i};
        d =  closest_data_points{i};
        q = project_point_on_line(m, d, camera_center);
        normals{i} = (q - m) / norm(q - m);
    end
    
    Fn = zeros(length(normals), 1); Jn = zeros(length(normals), D * length(centers));
    for i = 1:length(normals)
        Fn(i) = normals{i}' * F(D * (i - 1) + 1:D * i);
        Jn(i, :) = normals{i}' * J(D * (i - 1) + 1:D * i, :);
    end

    %[Fn, Jn] = silhouette_energy(centers, radii, blocks, points, data_bounding_box, settings);
    
    %% Rotations energy
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, mode);
        
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
    w1 = 1; w2 = 50; damping = 0.01;
    LHS = damping * I + w1 * (Jn' * Jn) + w2 * (J2' * J2);
    rhs = w1 * (Jn' * Fn) + w2 * (J2' * f2);       
    delta = -  LHS \ rhs;    
    
    disp(w1 * (Fn' * Fn) + w2 * (f2' * f2));
    
    %% Apply update
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    for o = 1:length(attachments)
        if isempty(attachments{o}), continue; end
        attachments{o}.axis_projection = zeros(D, 1);
        for l = 1:length(attachments{o}.indices)
            attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
        end
        direction = (centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)}) / ...
            norm(centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)});
        rotation = vrrotvec2mat(vrrotvec(attachments{o}.direction, direction));
        centers{o} = attachments{o}.axis_projection + rotation * attachments{o}.offset;
    end
    
end


