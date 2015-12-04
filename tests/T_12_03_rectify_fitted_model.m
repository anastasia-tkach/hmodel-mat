results_path = '_data/my_hand/model/';
load([results_path, 'centers.mat']);
load([results_path, 'radii.mat']);
load([results_path, 'blocks.mat']);

data_path = '_data/my_hand/trial1/';
load([data_path, '2_points.mat']); data_points = points;
compute_attachments;

%% Display data
figure; axis off; axis equal; hold on;
%display_result(centers, [], [], blocks, radii, false, 0.9);
display_skeleton(centers, radii, blocks, data_points, false);
%mypoints(data_points, [0.65, 0.1, 0.5]);
view([180, -90]); camlight; drawnow;

%% Rectify model

names_map_keys = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back'};
points = cell(length(names_map_keys), 1);
for i = 1:length(names_map_keys)
    points{i} = centers{names_map(names_map_keys{i})};
end
[hmodel_frame, hmodel_translation] = compute_principle_axis(points, false);
palm_normal = hmodel_frame(:, 3) / norm(hmodel_frame(:, 3));

%% Compute projections
named_attachments = {'pinky_membrane', 'ring_membrane', 'middle_membrane', 'index_membrane', 'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index'};
rectify_indices = zeros(length(attachments), 1);
for i = 1:length(named_attachments)
    rectify_indices(names_map(named_attachments{i})) = 1;
end

attachments_projections = cell(length(attachments), 1);
for i = 1:length(attachments)
    if rectify_indices(i)
        attachments_projections{i} = project_point_on_line(centers{i}, centers{blocks{attachments{i}.block_index}(1)}, centers{blocks{attachments{i}.block_index}(2)});
        offset_length = abs(get_convolution_radius_at_points(centers, radii, blocks{attachments{i}.block_index}, [], attachments_projections{i}) - radii{i});
        centers{i} = attachments_projections{i} + palm_normal * offset_length;
    end
end

figure; axis off; axis equal; hold on;
%display_result(centers, [], [], blocks, radii, false, 0.9);
display_skeleton(centers, radii, blocks, data_points, false);
%mypoints(data_points, [0.65, 0.1, 0.5]);
view([180, -90]); camlight; drawnow;

rectify_path = 'tracking/rectified/';
save([rectify_path, 'centers.mat'], 'centers');
save([rectify_path, 'radii.mat'], 'radii');
save([rectify_path, 'blocks.mat'], 'blocks');
save([rectify_path, 'theta.mat'], 'theta');

