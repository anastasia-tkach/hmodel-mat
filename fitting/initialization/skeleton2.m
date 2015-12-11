
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

centers_map('thumb_membrane') = a * centers_map('thumb_bottom') + (1 - a) * centers_map('thumb_base');
radii_map('thumb_membrane') = 0.070;

%% Attached bottom
centers_map('palm_top_right') = centers_map('pinky_base');
radii_map('palm_top_right') = radii_map('pinky_base');

centers_map('palm_top_left') = centers_map('index_base');
radii_map('palm_top_left') = radii_map('index_base');

centers_map('palm_middle') = 0.25 * centers_map('palm_top_left') + 0.25 * centers_map('palm_top_right') + ...
    0.25 * centers_map('palm_bottom_left')  + 0.25 * centers_map('palm_bottom_right');
radii_map('palm_middle') = 0.3;

centers_map('palm_bottom_middle') = 0.5 * centers_map('palm_bottom_left') + 0.5 * centers_map('palm_bottom_right');
radii_map('palm_bottom_middle') = 0.6;


%% Decrease radii
radii_map('pinky_base') = 0.9 * radii_map('pinky_bottom');
radii_map('ring_base') = 0.9 * radii_map('ring_bottom');
radii_map('middle_base') = 0.9 * radii_map('middle_bottom');
radii_map('index_base') = 0.9 * radii_map('index_bottom');

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
named_blocks{end + 1} = {'palm_top_left', 'palm_bottom_left', 'palm_middle'};
named_blocks{end + 1} = {'palm_top_left', 'palm_top_right', 'palm_middle'};
named_blocks{end + 1} = {'palm_top_right', 'palm_bottom_right', 'palm_middle'};
named_blocks{end + 1} = {'palm_bottom_left', 'palm_bottom_right', 'palm_middle'};

named_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

named_blocks{end + 1} = {'wrist_top_left', 'palm_bottom_middle', 'wrist_top_right'};

named_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'pinky_base'}; named_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'ring_base'};
named_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'ring_base'}; named_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'middle_base'};
named_blocks{end + 1} = {'middle_membrane', 'index_membrane', 'middle_base'}; named_blocks{end + 1} = {'middle_membrane', 'index_membrane', 'index_base'};

%named_blocks{end + 1} = {'thumb_membrane', 'thumb_index_membrane', 'thumb_base'};

%% Solids
named_solids = {};
% named_solids{end + 1} = {'palm_top_left', 'palm_bottom_left', 'palm_top_middle', 'palm_bottom_middle'};
% named_solids{end + 1} = {'palm_top_right', 'palm_bottom_right', 'palm_top_middle', 'palm_bottom_middle'};
% named_solids{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Read mesh

names = keys(centers_map);
names_map_keys = {
    'pinky_top', 'pinky_middle', 'pinky_bottom', 'pinky_base', ...
    'ring_top', 'ring_middle', 'ring_bottom', 'ring_base', ...
    'middle_top', 'middle_middle', 'middle_bottom', 'middle_base', ...
    'index_top', 'index_middle', 'index_bottom', 'index_base', ...
    'thumb_top', 'thumb_middle', 'thumb_bottom', 'thumb_base', ...
    'palm_top_left', 'palm_top_right', 'palm_middle', 'palm_bottom_left', 'palm_bottom_middle', 'palm_bottom_right', ...
    'wrist_top_left', 'wrist_top_right', 'wrist_bottom_left', 'wrist_bottom_right', ...
    'pinky_membrane', 'ring_membrane', 'middle_membrane', 'index_membrane', 'thumb_membrane'
    };
names_map = containers.Map(names_map_keys, 1:length(names_map_keys));

