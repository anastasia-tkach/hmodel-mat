function [attached_points, axis_projections, frames, attachments] = update_attachments(centers, blocks, attached_points, attachments, mode, global_frame_indices, names_map, names_map_keys)

D = length(centers{1});

axis_projections = cell(length(attachments), 1);

%frames = compute_model_frames(centers, blocks, global_frame_indices);
frames = compute_model_frames(centers, blocks, mode, global_frame_indices, names_map, names_map_keys);
for o = 1:length(attachments)
    if isempty(attachments{o}), continue; end
    if ~isfield(attachments{o}, 'indices'), continue; end
    
    axis_projections{o} = zeros(D, 1);
    for l = 1:length(attachments{o}.indices)
        axis_projections{o} = axis_projections{o} + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
    end
    rotation = find_svd_rotation(attachments{o}.frame, frames{attachments{o}.block_index});
    attached_points{o} = axis_projections{o} + rotation' * attachments{o}.offset;
    
    %% Display
    %{
    factor = 10;
    myline(centers{names_map('index_base')}, centers{names_map('index_base')} + factor *  attachments{o}.frame(:, 1), 'r');
    myline(centers{names_map('index_base')}, centers{names_map('index_base')} + factor *  attachments{o}.frame(:, 2), 'r');
    myline(centers{names_map('index_base')}, centers{names_map('index_base')} + factor *  attachments{o}.frame(:, 3), 'r');
    %}
    
end

