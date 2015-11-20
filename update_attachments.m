function [points, frames, attachments] = update_attachments(points, centers, blocks, attachments, global_frame_indices)

D = length(centers{1});

frames = compute_model_frames(centers, blocks, global_frame_indices);
for o = 1:length(attachments)
    if isempty(attachments{o}), continue; end
    if isempty(points{o}), continue; end
    
    attachments{o}.axis_projection = zeros(D, 1);
    for l = 1:length(attachments{o}.indices)
        attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
    end
    rotation = find_svd_rotation(attachments{o}.frame, frames{attachments{o}.block_index});
    points{o} = attachments{o}.axis_projection + rotation' * attachments{o}.offset;
end