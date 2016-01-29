right = centers_map('pinky_base') - centers_map('index_base');
up = centers_map('pinky_base') - centers_map('palm_right');
right = right / norm(right);
up = up / norm(up);
back = cross(up, right);


%% Attached bottom

centers_map('palm_center') = 0.25 * centers_map('palm_side') + 0.25 * centers_map('palm_thumb') + 0.25 * centers_map('palm_right') + 0.25 * centers_map('palm_left');

centers_map('palm_attachment') = 0.5 * centers_map('thumb_base') + 0.5 * centers_map('palm_right');
radii_map('palm_attachment') = 0.2;

centers_map('palm_bottom') = 0.5 * centers_map('thumb_base') + 0.5 * centers_map('palm_right') + 0.3 * back;
radii_map('palm_bottom') = 0.6;

centers_map('palm_top') = 0.5 * centers_map('palm_ring') + 0.5 * centers_map('palm_middle');
radii_map('palm_top') = 0.5 * radii_map('palm_ring') + 0.5 * radii_map('palm_middle');

centers_map('palm_bend') = 0.5 * centers_map('palm_top') + 0.5 * centers_map('palm_center');
radii_map('palm_bend') = 0.5 * radii_map('palm_top') + 0.5 * radii_map('palm_center');

%% Attached top
a = 0.45;
centers_map('pinky_membrane') = a * centers_map('pinky_bottom') + (1 - a) * centers_map('pinky_base');
radii_map('pinky_membrane') = 0.069;

centers_map('ring_membrane') = a * centers_map('ring_bottom') + (1 - a) * centers_map('ring_base');
radii_map('ring_membrane') = 0.070;

centers_map('middle_membrane') = a * centers_map('middle_bottom') + (1 - a) * centers_map('middle_base');
radii_map('middle_membrane') = 0.071;

centers_map('index_membrane') = a * centers_map('index_bottom') + (1 - a) * centers_map('index_base');
radii_map('index_membrane') = 0.070;

u = centers_map('thumb_bottom') - centers_map('thumb_base');
v = cross(back, u); v = v / norm(v);
centers_map('thumb_membrane') = 0.7 * centers_map('thumb_bottom') + 0.3 * centers_map('thumb_middle');
radii_map('thumb_membrane') = radii_map('thumb_middle');


%% Blocks fingers
named_blocks = {};
named_blocks{end + 1} = {'pinky_top', 'pinky_middle'};
named_blocks{end + 1} = {'pinky_middle', 'pinky_bottom'};
named_blocks{end + 1} = {'pinky_bottom', 'pinky_base'};

named_blocks{end + 1} = {'ring_top', 'ring_middle'};
named_blocks{end + 1} = {'ring_middle', 'ring_bottom'};
named_blocks{end + 1} = {'ring_bottom', 'ring_base'};

named_blocks{end + 1} = {'middle_top', 'middle_middle'};
named_blocks{end + 1} = {'middle_middle', 'middle_bottom'};
named_blocks{end + 1} = {'middle_bottom', 'middle_base'};

named_blocks{end + 1} = {'index_top', 'index_middle'};
named_blocks{end + 1} = {'index_middle', 'index_bottom'};
named_blocks{end + 1} = {'index_bottom', 'index_base'};

named_blocks{end + 1} = {'thumb_top', 'thumb_middle'};
named_blocks{end + 1} = {'thumb_middle', 'thumb_bottom'};
named_blocks{end + 1} = {'thumb_bottom', 'thumb_base'};

%% Blocks attachment
named_blocks{end + 1} = {'pinky_base', 'palm_attachment'};
named_blocks{end + 1} = {'ring_base', 'palm_attachment'};
named_blocks{end + 1} = {'middle_base', 'palm_attachment'};
named_blocks{end + 1} = {'index_base', 'palm_attachment'};

%% Blocks thumb fold
named_blocks{end + 1} = {'thumb_membrane', 'thumb_fold', 'thumb_base'};
named_blocks{end + 1} = {'thumb_fold', 'palm_thumb', 'thumb_base'};
named_blocks{end + 1} = {'thumb_additional', 'thumb_top'};
named_blocks{end + 1} = {'palm_left', 'thumb_base'};

%% Blocks membrane
named_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'}; 
named_blocks{end + 1} = {'palm_pinky', 'palm_top', 'ring_membrane'};
named_blocks{end + 1} = {'ring_membrane', 'palm_top', 'middle_membrane'}; 
named_blocks{end + 1} = {'middle_membrane', 'palm_top', 'palm_index'}; 
named_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};

%% Blocks palm
named_blocks{end + 1} = {'palm_pinky', 'palm_side', 'palm_top'};
named_blocks{end + 1} = {'palm_side', 'palm_top', 'palm_bend'};
named_blocks{end + 1} = {'palm_top', 'palm_bend', 'palm_thumb'};
named_blocks{end + 1} = {'palm_top', 'palm_index', 'palm_thumb'};

named_blocks{end + 1} = {'palm_side', 'palm_bend', 'palm_center'};
named_blocks{end + 1} = {'palm_bend', 'palm_center', 'palm_thumb'};
named_blocks{end + 1} = {'palm_side', 'palm_center', 'palm_right'};
named_blocks{end + 1} = {'palm_right', 'palm_center', 'palm_bottom'};
named_blocks{end + 1} = {'palm_bottom', 'palm_center', 'palm_left'};
named_blocks{end + 1} = {'palm_left', 'palm_center', 'palm_thumb'};

%% Wrist blocks
named_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};
named_blocks{end + 1} = {'wrist_top_left', 'wrist_top_right', 'palm_bottom'};

%% Read mesh

names = keys(centers_map);
names_map_keys = {
    'pinky_top', 'pinky_middle', 'pinky_bottom', 'pinky_base', ...
    'ring_top', 'ring_middle', 'ring_bottom', 'ring_base', ...
    'middle_top', 'middle_middle', 'middle_bottom', 'middle_base', ...
    'index_top', 'index_middle', 'index_bottom', 'index_base', ...
    'thumb_top', 'thumb_middle', 'thumb_bottom', 'thumb_base', ...
    'palm_pinky', 'palm_top', 'palm_index', 'palm_side', 'palm_bend', 'palm_thumb', 'palm_center', ...
    'palm_bottom', 'palm_attachment', 'palm_right', 'palm_left', ...    
    'pinky_membrane', 'ring_membrane', 'middle_membrane', 'index_membrane', 'thumb_membrane', 'thumb_additional', 'thumb_fold'...
    'wrist_top_left', 'wrist_top_right', 'wrist_bottom_left', 'wrist_bottom_right'
    };
names_map = containers.Map(names_map_keys, 1:length(names_map_keys));

