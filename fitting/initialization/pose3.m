close all;
centers_map = containers.Map();
radii_map = containers.Map();

%% Pinky
centers_map('pinky_top') = [-1.46; -1.984; -0.419];
radii_map('pinky_top') = 0.16;

centers_map('pinky_middle') = [-0.986; -1.698; -0.225];
radii_map('pinky_middle') = 0.18;

centers_map('pinky_bottom') = [-0.506; -1.324; 0.059];
radii_map('pinky_bottom') = 0.22;

centers_map('pinky_base') = [0.153; -0.688; 0.503];
radii_map('pinky_base') = 0.27;

%% Ring
centers_map('ring_top') = [-1.979; -2.129; 0.188];
radii_map('ring_top') = 0.16;

centers_map('ring_middle') = [-1.644; -1.811; 0.425];
radii_map('ring_middle') = 0.17;

centers_map('ring_bottom') = [-1.103; -1.193; 0.769];
radii_map('ring_bottom') = 0.22;

centers_map('ring_base') = [-0.112; -0.278; 0.6];
radii_map('ring_base') = 0.3;

%% Middle
centers_map('middle_top') = [-2.522; -1.569; 2.042];
radii_map('middle_top') = 0.18;

centers_map('middle_middle') = [-2.079; -1.214; 1.741];
radii_map('middle_middle') = 0.20;

centers_map('middle_bottom') = [-1.496; -0.701; 1.396];
radii_map('middle_bottom') = 0.27;

centers_map('middle_base') = [-0.476; -0.001; 0.627];
radii_map('middle_base') = 0.3;

%% Index
centers_map('index_top') = [-2.663; -1.372; 0.496];
radii_map('index_top') = 0.18;

centers_map('index_middle') = [-2.399; -0.996; 0.637];
radii_map('index_middle') = 0.2;

centers_map('index_bottom') = [-1.963; -0.379; 0.77];
radii_map('index_bottom') = 0.27;

centers_map('index_base') = [-0.948; 0.247; 0.31];
radii_map('index_base') = 0.27;

%% Thumb
centers_map('thumb_fold') = [-0.54; -0.314; -0.548];
radii_map('thumb_fold') = 0.2;

centers_map('thumb_additional') = [-1.497; -1.955; -0.727];
radii_map('thumb_additional') = 0.15;

centers_map('thumb_top') = [-1.314; -1.769; -0.683];
radii_map('thumb_top') = 0.21;

centers_map('thumb_middle') = [-0.982; -1.334; -0.796];
radii_map('thumb_middle') = 0.26;

centers_map('thumb_bottom') = [-0.517; -0.638; -0.992];
radii_map('thumb_bottom') = 0.34;

centers_map('thumb_base') = [0.023; -0.223; -0.998];
radii_map('thumb_base') = 0.5;

%% Palm top
centers_map('palm_pinky') = [0.297; -0.721; 0.225];
radii_map('palm_pinky') = 0.35;

centers_map('palm_ring') = [-0.216; -0.49; 0.458];
radii_map('palm_ring') = 0.35;

centers_map('palm_middle') = [-0.548; -0.201; 0.584];
radii_map('palm_middle') = 0.4;

centers_map('palm_index') = [-0.995; 0.053; 0.27];
radii_map('palm_index') = 0.35;

% centers_map('palm_thumb') = [-0.852; 0.139; 0.021];
% radii_map('palm_thumb') = 0.32;

centers_map('palm_thumb') = [-0.953; 0.115; -0.042];
radii_map('palm_thumb') = 0.2;

%% Palm bottom
centers_map('palm_right') = [1.078; -0.031; -0.684];
radii_map('palm_right') = 0.59;

centers_map('palm_left') = [0.447; 0.196; -1.019];
radii_map('palm_left') = 0.5;

%% Wrist
centers_map('wrist_top_left') = [1.626; 0.205; -1.003];
radii_map('wrist_top_left') = 0.55;

centers_map('wrist_top_right') = [1.313; 0.531; -1.141];
radii_map('wrist_top_right') = 0.55;

centers_map('wrist_bottom_right') = [3.039; 0.601; -2.174];
radii_map('wrist_bottom_right') = 0.55;

centers_map('wrist_bottom_left') = [3.197; 0.139; -1.939];
radii_map('wrist_bottom_left') = 0.55;

