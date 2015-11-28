function [model_points, axis_projections, frames, attachments] = update_attachments(centers, blocks, attachments, global_frame_indices)

D = length(centers{1});

model_points = cell(length(attachments), 1);
axis_projections = cell(length(attachments), 1);

frames = compute_model_frames(centers, blocks, global_frame_indices);
for o = 1:length(attachments)
    if isempty(attachments{o}), continue; end
    if ~isfield(attachments{o}, 'indices'), continue; end
   
    axis_projections{o} = zeros(D, 1);
    for l = 1:length(attachments{o}.indices)
        axis_projections{o} = axis_projections{o} + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
    end
    rotation = find_svd_rotation(attachments{o}.frame, frames{attachments{o}.block_index});
    model_points{o} = axis_projections{o} + rotation' * attachments{o}.offset;
end

save rotation rotation;