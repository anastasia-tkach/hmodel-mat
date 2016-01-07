close all; clear;

D = 3;

mode = 'points';

switch mode
    case 'centers'
        %% Hand model
        model_path = '_data/my_hand/model/';
        data_path = '_data/my_hand/trial1/';
        load([model_path, 'centers.mat']);
        load([model_path, 'radii.mat']);
        load([model_path, 'blocks.mat']);
        load([model_path, 'solids.mat']);
        
        compute_attachments;
        initial_centers = centers;
        figure; axis off; axis equal; hold on;
        display_skeleton(initial_centers, radii, blocks, [], false);
        
        attachments = initialize_attachments(centers, radii, blocks, centers, attachments, global_frame_indices);
        
        %% Generate model
        rotation_axis = randn(D, 1);
        rotation_angle = 10 * randn;
        translation_vector = - rand * [0; 0; 1];
        R = makehgtform('axisrotate', rotation_axis, rotation_angle);
        T = makehgtform('translate', translation_vector);
        for i = 1:length(centers)
            centers{i} = transform(centers{i}, R);
            centers{i} = transform(centers{i}, T);
        end
        
        %% Attachments
        [model_points, axis_projections, frames, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        
        for i = 1:length(model_points)
            if ~isempty(model_points{i})
                centers{i} = model_points{i};
            end
        end
        
        figure; axis off; axis equal; hold on;
        display_skeleton(centers, radii, blocks, [], false);
        
        %% Transform
        load rotation
        T2 = T;
        T2(1:3, 4) = - T(1:3, 4);
        R2 = eye(4, 4);
        R2(1:3, 1:3) = rotation;
        for i = 1:length(centers)
            centers{i} = transform(centers{i}, T2);
            centers{i} = transform(centers{i}, R2);
        end
        
        %% Display results
       
        figure; axis off; axis equal; hold on;
        display_skeleton(centers, radii, blocks, [], false);
        
        for i = 1:length(centers)
            disp([initial_centers{i}'; centers{i}']);
        end
        
    case 'points'
        %% Synthetic data
        [centers, radii, blocks] = get_random_convtriangle();
        radii{1} = 0.19; radii{2} = 0.2; radii{3} = 0.21;
        
        centers{4} = mean([centers{1}, centers{2}, centers{3}], 2);
        centers{5} = centers{4} + 2 * cross(centers{2} - centers{1}, centers{3} - centers{1});
        radii{4} = 0.15; radii{5} = 0.1;
        blocks{2} = [4, 5];
        global_frame_indices = blocks{1};
        
        num_samples = 500;
        data_points = generate_convtriangles_points(centers, blocks, radii, num_samples);
        
        %% Generate model
        rotation_axis = randn(D, 1); rotation_angle = 0.1 * randn;
        translation_vector = 0.1 * randn(D, 1);
        R = makehgtform('axisrotate', rotation_axis, rotation_angle);
        T = makehgtform('translate', translation_vector);
        for i = 1:length(centers)
            centers{i} = transform(centers{i}, R);
            centers{i} = transform(centers{i}, T);
        end
        
        [model_indices, model_points, block_indices, axis_projections] = compute_projections_matlab(data_points, centers, blocks, radii);
        
        attachments = cell(length(model_indices), 1);
        for i = 1:length(attachments), attachments{i}.block_index = block_indices{i}; end
        attachments = initialize_attachments(centers, radii, blocks, model_points, attachments, global_frame_indices);
        
        [model_points, axis_projections, frames, attachments] = update_attachments(centers, blocks, model_points, attachments, global_frame_indices);
       
        %% Display
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
        %mylines(data_points, model_points, [0.75, 0.75, 0.75]);
        mypoints(data_points, [0.65, 0.1, 0.5]);
        mylines(axis_projections, model_points, [0.75, 0.75, 0.75]);
        mypoints(model_points, [0, 0.7, 1]);
        mypoints(axis_projections, 'r');
        camlight; drawnow;
        
        %% Transform model
        rotation_axis = randn(D, 1);
        rotation_angle = 1 * randn;
        translation_vector = 0.6 * randn(D, 1);
        R = makehgtform('axisrotate', rotation_axis, rotation_angle);
        T = makehgtform('translate', translation_vector);
        for i = 1:length(centers)
            centers{i} = transform(centers{i}, R);
            centers{i} = transform(centers{i}, T);
        end
        
        %% Attachments
        [model_points, axis_projections, frames, attachments] = update_attachments(centers, blocks, model_points, attachments, global_frame_indices);
        
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
        %mylines(data_points, model_points, [0.75, 0.75, 0.75]);
        mypoints(data_points, [0.65, 0.1, 0.5]);
        mylines(axis_projections, model_points, [0.75, 0.75, 0.75]);
        mypoints(model_points, [0, 0.7, 1]);
        mypoints(axis_projections, 'r');
        camlight; drawnow;       
        
        %% Transform
        initial_centers = centers;
        initial_model_points = model_points;
        initial_axis_projections = axis_projections;
        load rotation;
        T2 = T;
        T2(1:3, 4) = - T(1:3, 4);
        R2 = eye(4, 4);
        R2(1:3, 1:3) = rotation;
        for i = 1:length(centers)
            centers{i} = transform(centers{i}, T2);
            centers{i} = transform(centers{i}, R2);
        end
        for i = 1:length(model_points)
            model_points{i} = transform(model_points{i}, T2);
            model_points{i} = transform(model_points{i}, R2);
            
            axis_projections{i} = transform(axis_projections{i}, T2);
            axis_projections{i} = transform(axis_projections{i}, R2);
        end
        
        %% Display results
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, false);
        display_skeleton(centers, radii, blocks, [], false);
        %mylines(data_points, model_points, [0.75, 0.75, 0.75]);
        mypoints(data_points, [0.65, 0.1, 0.5]);
        mylines(axis_projections, model_points, [0.75, 0.75, 0.75]);
        mypoints(model_points, [0, 0.7, 1]);
        mypoints(axis_projections, 'r');
        camlight; drawnow;   
end



