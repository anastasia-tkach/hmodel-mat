%% Solid blocks
named_solid_blocks = {};
named_solid_blocks{end + 1} = {...
{'palm_pinky', 'palm_ring', 'palm_right'}, ...
{'palm_right', 'palm_ring', 'palm_back'}, ...
{'palm_ring', 'palm_middle', 'palm_back'}, ...
{'palm_back', 'palm_middle', 'palm_left'}, ...
{'palm_middle', 'palm_index', 'palm_left'}, ...
% {'palm_index', 'palm_thumb', 'palm_left'}, ...
% {'palm_left', 'palm_thumb', 'thumb_base'}, ...
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

named_elastic_blocks{end + 1} = {'thumb_bottom', 'thumb_fold', 'thumb_base'};
named_elastic_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_elastic_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Phantom blocks
named_phantom_blocks = {};
named_phantom_blocks{end + 1} = {'pinky_base', 'palm_pinky'};
named_phantom_blocks{end + 1} = {'ring_base', 'palm_ring'};
named_phantom_blocks{end + 1} = {'middle_base', 'palm_middle'};
named_phantom_blocks{end + 1} = {'index_base', 'palm_index'};


%% Blocks to skip in fist
named_fist_skip_blocks = {}; 

named_fist_skip_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'}; 
named_fist_skip_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_fist_skip_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'}; 
named_fist_skip_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};
named_fist_skip_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'}; 
named_fist_skip_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};

