function [attachments, frames] = initialize_attachments(points, centers, blocks, attachments, global_frame_indices)

%% Compute attachment weights
frames = compute_model_frames(centers, blocks, global_frame_indices);
for i = 1:length(attachments)
    if isempty(attachments{i}), continue; end    
    if isempty(points{i}), continue; end
    attachments{i}.indices = blocks{attachments{i}.block_index};
    attachments{i}.frame = frames{attachments{i}.block_index};
    [~, projections, ~] = compute_skeleton_projections({points{i}}, centers, {attachments{i}.indices});
    attachments{i}.axis_projection = projections{1};       
    if length(attachments{i}.indices) == 3
        P = [centers{attachments{i}.indices(1)}'; centers{attachments{i}.indices(2)}'; centers{attachments{i}.indices(3)}'; attachments{i}.axis_projection'];
        attachments{i}.weights = [P(4,:),1]/[P(1:3,:),ones(3,1)];
    end
    if length(attachments{i}.indices) == 2
        P = [centers{attachments{i}.indices(1)}'; centers{attachments{i}.indices(2)}'; attachments{i}.axis_projection'];
        attachments{i}.weights = [P(3,:),1]/[P(1:2,:),ones(2,1)];
    end    
    attachments{i}.offset = points{i}  - attachments{i}.axis_projection;
end