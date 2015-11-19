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
% % [centers, radii, blocks] = get_random_convtriangle();
% % edge_indices = {{[1, 2], [1, 3], [2, 3]}};
% 
% [centers, radii, blocks] = get_random_convsegment();
% edge_indices = {{[1, 2]}};
% 
% %[centers, radii, blocks] = get_random_sphere();
% 
% % data_bounding_box = compute_model_bounding_box(centers, radii);
% % model_points  = [];
% % [raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
% % rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
% 
% % [I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));
% % N = length(model_points);
% % model_points = [model_points; cell(length(I), 1)];
% % for k = 1:length(I), model_points{N + k} = squeeze(rendered_model(I(k), J(k), :)); end
% % data_points = model_points;
% 
% data_points = generate_convtriangles_points(centers, blocks, radii);
% 
% %data_points = sample_skeleton(centers, blocks);
% 
% %% Generate model
% rotation_axis = randn(D, 1); rotation_angle = randn;
% translation_vector = randn(D, 1);
% R = makehgtform('axisrotate', rotation_axis, rotation_angle);
% T = makehgtform('translate', translation_vector);
% for i = 1:length(centers)
%     centers{i} = transform(centers{i}, R);
%     centers{i} = transform(centers{i}, T);
% end
% 
% data_bounding_box = compute_data_bounding_box(data_points);
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
% 
% attachments = cell(length(centers), 1);
% initial_centers = centers;
% initial_data_points = data_points;


%% Optimizaion
close all;
centers = initial_centers;
data_points = initial_data_points;

% i = randi([1, length(data_points)],1 , 1);
% data_points = data_points(i);

for iter = 1:6
    
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    %[model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    [model_indices, model_points, block_indices] = compute_projections_matlab(data_points, centers, blocks, radii);
    %[model_indices, model_points, block_indices] = compute_skeleton_projections(data_points, centers, blocks);
    
%         new_data_points = [];
%         new_model_points = [];
%         new_model_indices = [];
%         new_block_indices = [];
%         for i = 1:length(data_points)
%             if length(model_indices{i}) == 1
%                 new_model_indices{end + 1} = model_indices{i};
%                 new_data_points{end + 1} = data_points{i};
%                 new_model_points{end + 1} = model_points{i};
%                 new_block_indices{end + 1} = block_indices{i};
%             end
%         end
%         model_indices = new_model_indices;
%         data_points = new_data_points;
%         model_points = new_model_points;
%         block_indices = new_block_indices;
    
    %% Compute projections locations
%     offsets = cell(length(block_indices), 1);
%     directions = cell(length(block_indices), 1);
%     for i = 1:length(block_indices)
%         if isempty(model_points{i}), continue; end
%         if length(blocks{block_indices{i}}) == 1
%             offsets{i} = model_points{i}  - centers{blocks{block_indices{i}}(1)};
%             continue;
%         end
%         c1 = centers{blocks{block_indices{i}}(1)}; c2 = centers{blocks{block_indices{i}}(2)};
%         offsets{i} = model_points{i}  - c1; directions{i} = (c2 - c1) / norm(c2 - c1);
%     end
%     
%     for inner_iter = 1:1
%         
%         %% Compute model points
%         for i = 1:length(block_indices)
%             if isempty(model_points{i}), continue; end
%             if length(blocks{block_indices{i}}) == 1
%                 model_points{i}  = centers{blocks{block_indices{i}}(1)} + offsets{i};
%                 continue;
%             end
%             c1 = centers{blocks{block_indices{i}}(1)}; c2 = centers{blocks{block_indices{i}}(2)};
%             direction = (c2 - c1) / norm(c2 - c1);
%             rotation = vrrotvec2mat(vrrotvec(directions{i}, direction));
%             model_points{i} = c1 + rotation * offsets{i};
%         end
        
        %% Display
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
        
        %figure; axis equal; axis off; hold on; set(gcf,'color','white');
        %for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
        %    scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
        %    line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        %end;
        
        %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        mypoints(data_points, [0.65, 0.1, 0.5]);
        mypoints(model_points, [0, 0.7, 1]);
        %view([-180, -90]); %xlim([-1.5; 1]); ylim([-0.5; 1.5]);
        camlight; drawnow;
        
        %% Translations energy
        [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D, iter == 1);
        %[f1, J1] = jacobian_arap_translation_skeleton_attachment(centers, model_points, model_indices, data_points, attachments, D);
        
        %% Rotations energy
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, mode);
        
        %% Compute update
        I = eye(D * length(centers), D * length(centers));
        w1 = 1; w2 = 20; damping = 0.01;
        
        %LHS = damping * I + w2 * (J2' * J2) + w1 * (Jn' * Jn);
        %rhs = w2 * (J2' * f2) + w1 * (Jn' * Fn);
        
        LHS = damping * I + w2 * (J2' * J2) + w1 * (J1' * J1);
        rhs = w2 * (J2' * f2) + w1 * (J1' * f1);
        
        %LHS = damping * I +  w1 * (J1' * J1);
        %rhs = w1 * (J1' * f1);
        
        delta = - LHS \ rhs;
        
        disp(f1' * f1);
        
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
    %end
    
end