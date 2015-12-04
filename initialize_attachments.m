function [attachments, frames] = initialize_attachments...
    (centers, radii, blocks, attached_points, attachments, mode, global_frame_indices, names_map, names_map_keys)

tangent_points = blocks_tangent_points(centers, blocks, radii);
axis_projections = cell(length(attached_points), 1);

%% Compute attachment weights
%frames = compute_model_frames(centers, blocks, global_frame_indices);
frames = compute_model_frames(centers, blocks, mode, global_frame_indices, names_map, names_map_keys);
for i = 1:length(attachments)

    if isempty(attachments{i}), continue; end
    if isempty(attached_points{i}), continue; end

    attachments{i}.indices = blocks{attachments{i}.block_index};
    attachments{i}.frame = frames{attachments{i}.block_index};

    [~, ~, axis_projections{i}, ~] = projection(attached_points{i}, attachments{i}.indices, radii, centers, tangent_points{attachments{i}.block_index});
    %[~, projections, ~] = compute_skeleton_projections({points{i}}, centers, {attachments{i}.indices});
    %attachments{i}.axis_projection = projections{1}; 
    
    if length(attachments{i}.indices) == 3
       P = [centers{attachments{i}.indices(1)}'; centers{attachments{i}.indices(2)}'; centers{attachments{i}.indices(3)}'; axis_projections{i}'];
       attachments{i}.weights = [P(4,:),1]/[P(1:3,:),ones(3,1)];
    end
    if length(attachments{i}.indices) == 2
       P = [centers{attachments{i}.indices(1)}'; centers{attachments{i}.indices(2)}'; axis_projections{i}'];
       attachments{i}.weights = [P(3,:),1]/[P(1:2,:),ones(2,1)];
    end
    
    attachments{i}.offset = attached_points{i} - axis_projections{i};
end