%% Solid blocks
named_solid_blocks = {};
named_solid_blocks{end + 1} = {
	{'palm_middle', 'palm_left', 'palm_back'}, ...
	{'palm_middle', 'palm_index', 'palm_left'}, ...
    {'palm_right', 'palm_ring', 'palm_back'}, ...
    {'palm_ring', 'palm_middle', 'palm_back'}, ...
    {'middle_base', 'palm_attachment'}, ...
    {'ring_base', 'palm_attachment'}, ...
};

%% Elastic blocks
named_elastic_blocks = {};
named_elastic_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'};
named_elastic_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_elastic_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'};
named_elastic_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};
named_elastic_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'};
named_elastic_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};
named_elastic_blocks{end + 1} = {'thumb_membrane', 'thumb_base', 'thumb_fold'};
named_elastic_blocks{end + 1} = {'thumb_fold', 'palm_thumb', 'thumb_base'};
named_elastic_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_elastic_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Phantom blocks
named_phantom_blocks = {};
named_phantom_blocks{end + 1} = {'pinky_base', 'palm_pinky', 'pinky_membrane'};
named_phantom_blocks{end + 1} = {'ring_base', 'palm_ring', 'ring_membrane'};
named_phantom_blocks{end + 1} = {'middle_base', 'palm_middle', 'middle_membrane'};
named_phantom_blocks{end + 1} = {'index_base', 'palm_index', 'index_membrane'};

named_phantom_blocks{end + 1} = {'thumb_bottom', 'thumb_membrane'};

named_phantom_blocks{end + 1} = {'palm_index', 'palm_left', 'palm_thumb'};

named_phantom_blocks{end + 1} = {'palm_index', 'palm_left', 'palm_thumb'};

named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_right'};
named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_left'};
named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_back'};

%% Smooth blocks
named_smooth_blocks = {};
named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'};
named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};
named_smooth_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};

named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_smooth_blocks{end + 1} = {'palm_right', 'palm_ring', 'palm_back'};
named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_smooth_blocks{end + 1} = {'palm_middle', 'palm_left', 'palm_back'};
named_smooth_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'};
named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_smooth_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'};
named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};

named_smooth_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_smooth_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Tangent blocks-spheres pairs
named_tangent_blocks = {};
named_tangent_spheres = {};

named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_spheres{end + 1} = 'pinky_base';

named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_spheres{end + 1} = 'ring_base';

named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_spheres{end + 1} = 'ring_base';

named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_spheres{end + 1} = 'middle_base';

named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
named_tangent_spheres{end + 1} = 'middle_base';

named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
named_tangent_spheres{end + 1} = 'index_base';

% named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
% named_tangent_spheres{end + 1} = 'palm_thumb';

%% Attachments
attachments_map = containers.Map();

attachments_map('pinky_membrane') = {'pinky_bottom', 'pinky_base'};
attachments_map('ring_membrane') = {'ring_bottom', 'ring_base'};
attachments_map('middle_membrane') = {'middle_bottom', 'middle_base'};
attachments_map('index_membrane') = {'index_bottom', 'index_base'};
attachments_map('thumb_membrane') = {'thumb_bottom', 'thumb_middle'};

attachments_map('palm_pinky') = {'pinky_bottom', 'pinky_base'};
attachments_map('palm_ring') = {'ring_bottom', 'ring_base'};
attachments_map('palm_middle') = {'middle_bottom', 'middle_base'};
attachments_map('palm_index') = {'index_bottom', 'index_base'};

attachments_map('thumb_base') = {'palm_middle', 'palm_left', 'palm_index'};
attachments_map('palm_thumb') = {'palm_middle', 'palm_left', 'palm_index'};
attachments_map('thumb_additional') = {'thumb_middle', 'thumb_top'};

attachments_map('palm_attachment') = {'palm_right', 'palm_back', 'palm_left'};

%% Parents
parents_map = containers.Map();

parents_map('pinky_top pinky_middle') = {'pinky_middle', 'pinky_bottom'};
parents_map('pinky_middle pinky_bottom') = {'pinky_bottom', 'pinky_base'};
parents_map('pinky_bottom pinky_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('ring_top ring_middle') = {'ring_middle', 'ring_bottom'};
parents_map('ring_middle ring_bottom') = {'ring_bottom', 'ring_base'};
parents_map('ring_bottom ring_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('middle_top middle_middle') = {'middle_middle', 'middle_bottom'};
parents_map('middle_middle middle_bottom') = {'middle_bottom', 'middle_base'};
parents_map('middle_bottom middle_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('index_top index_middle') = {'index_middle', 'index_bottom'};
parents_map('index_middle index_bottom') = {'index_bottom', 'index_base'};
parents_map('index_bottom index_base') = {'palm_right', 'palm_back', 'palm_ring'};

parents_map('thumb_top thumb_middle') = {'thumb_middle', 'thumb_bottom'};
parents_map('thumb_middle thumb_bottom') = {'thumb_bottom', 'thumb_base'};
parents_map('thumb_bottom thumb_base') = {'palm_right', 'palm_back', 'palm_ring'};

%% Global frame
named_global_frame_block = {'palm_ring', 'palm_middle', 'palm_back'};

%% Palm centers names
palm_centers_names = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back'};