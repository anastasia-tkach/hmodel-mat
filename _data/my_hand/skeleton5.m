right = centers_map('pinky_base') - centers_map('index_base');
up = centers_map('pinky_base') - centers_map('palm_right');
right = right / norm(right);
up = up / norm(up);
back = cross(up, right);


%% Attached bottom
centers_map('palm_pinky') = centers_map('pinky_base');
radii_map('palm_pinky') = radii_map('pinky_base');

centers_map('palm_index') = centers_map('index_base');
radii_map('palm_index') = radii_map('index_base');

centers_map('palm_attachment') = 0.5 * centers_map('palm_left') + 0.5 * centers_map('palm_right');
radii_map('palm_attachment') = 0.4;

centers_map('palm_back') = 0.5 * centers_map('palm_left') + 0.5 * centers_map('palm_right') + 0.3 * back;
radii_map('palm_back') = 0.6;

centers_map('palm_front') = 0.5 * centers_map('palm_left') + 0.5 * centers_map('palm_right') - 0.1 * back;
radii_map('palm_front') = 0.5;

centers_map('palm_ring') = 0.34 * centers_map('palm_index') + 0.66 * centers_map('palm_pinky');
radii_map('palm_ring') = radii_map('palm_pinky');

centers_map('palm_middle') = 0.66 * centers_map('palm_index') + 0.34 * centers_map('palm_pinky');
radii_map('palm_middle') = radii_map('palm_index');


%% Decrease radii
factor = 0.2;
radii_map('pinky_base') = 0.9 * radii_map('pinky_bottom');
radii_map('ring_base') = 0.9 * radii_map('ring_bottom');
radii_map('middle_base') = 0.9 * radii_map('middle_bottom');
radii_map('index_base') = 0.9 * radii_map('index_bottom');
centers_map('pinky_base') = centers_map('pinky_base') + factor * back;
centers_map('ring_base') = centers_map('ring_base') + factor * back;
centers_map('middle_base') = centers_map('middle_base') + factor * back;
centers_map('index_base') = centers_map('index_base') + factor * back;

%% Attached top
a = 0.45;
centers_map('pinky_membrane') = a * centers_map('pinky_bottom') + (1 - a) * centers_map('pinky_base');
radii_map('pinky_membrane') = 0.070;

centers_map('ring_membrane') = a * centers_map('ring_bottom') + (1 - a) * centers_map('ring_base');
radii_map('ring_membrane') = 0.070;

centers_map('middle_membrane') = a * centers_map('middle_bottom') + (1 - a) * centers_map('middle_base');
radii_map('middle_membrane') = 0.070;

centers_map('index_membrane') = a * centers_map('index_bottom') + (1 - a) * centers_map('index_base');
radii_map('index_membrane') = 0.070;

u = centers_map('thumb_bottom') - centers_map('thumb_base');
v = cross(back, u); v = v / norm(v);
centers_map('thumb_membrane') = 0.7 * centers_map('thumb_bottom') + 0.3 * centers_map('thumb_middle');
radii_map('thumb_membrane') = radii_map('thumb_middle');

centers_map('palm_thumb') = 0.5 * centers_map('index_base') + 0.5 * centers_map('thumb_base');
radii_map('palm_thumb') = 0.2;


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

%% Blocks palm
named_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_thumb'};
named_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};

named_blocks{end + 1} = {'palm_middle', 'palm_thumb', 'palm_front'};
named_blocks{end + 1} = {'palm_thumb', 'thumb_base', 'palm_front'}; 
named_blocks{end + 1} = {'palm_right', 'palm_ring', 'palm_front'};
named_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_front'};

named_blocks{end + 1} = {'palm_middle', 'palm_thumb', 'palm_back'};
named_blocks{end + 1} = {'palm_thumb', 'thumb_base', 'palm_back'}; 
named_blocks{end + 1} = {'palm_right', 'palm_ring', 'palm_back'};
named_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_back'};

named_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};

named_blocks{end + 1} = {'pinky_base', 'palm_attachment'};
named_blocks{end + 1} = {'ring_base', 'palm_attachment'};
named_blocks{end + 1} = {'middle_base', 'palm_attachment'};
named_blocks{end + 1} = {'index_base', 'palm_attachment'};

named_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};
named_blocks{end + 1} = {'wrist_top_left', 'palm_back', 'wrist_top_right'};

named_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'}; named_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'}; named_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};
named_blocks{end + 1} = {'middle_membrane', 'index_membrane', 'palm_middle'}; named_blocks{end + 1} = {'palm_middle', 'palm_index', 'index_membrane'};

named_blocks{end + 1} = {'thumb_membrane', 'palm_thumb', 'thumb_base'};

%% Solids
named_solids = {};
% named_solids{end + 1} = {'palm_index', 'palm_left', 'palm_top_middle', 'palm_attachment'};
% named_solids{end + 1} = {'palm_pinky', 'palm_right', 'palm_top_middle', 'palm_attachment'};
% named_solids{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Read mesh

names = keys(centers_map);
names_map_keys = {
    'pinky_top', 'pinky_middle', 'pinky_bottom', 'pinky_base', ...
    'ring_top', 'ring_middle', 'ring_bottom', 'ring_base', ...
    'middle_top', 'middle_middle', 'middle_bottom', 'middle_base', ...
    'index_top', 'index_middle', 'index_bottom', 'index_base', ...
    'thumb_top', 'thumb_middle', 'thumb_bottom', 'thumb_base', ...
    ...
    'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', ...
    'palm_back', 'palm_front', 'palm_attachment', 'palm_right', ...
    'wrist_top_left', 'wrist_top_right', 'wrist_bottom_left', 'wrist_bottom_right', ...
    'pinky_membrane', 'ring_membrane', 'middle_membrane', 'index_membrane', 'thumb_membrane', ...
    };
names_map = containers.Map(names_map_keys, 1:length(names_map_keys));


