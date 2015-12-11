close all;
centers_map = containers.Map();
radii_map = containers.Map();

%% Pinky
centers_map('pinky_top') = [-1.513; 1.223; 0.432];
radii_map('pinky_top') = 0.16;

centers_map('pinky_middle') = [-1.821; 1.218; 0.778];
radii_map('pinky_middle') = 0.18;

centers_map('pinky_bottom') = [-2.155; 1.462; 0.515];
radii_map('pinky_bottom') = 0.22;

centers_map('pinky_base') = [-1.66; 1.377; -0.297];
radii_map('pinky_base') = 0.27;

%% Ring
centers_map('ring_top') = [-1.553; 0.707; 0.174];
radii_map('ring_top') = 0.18;

centers_map('ring_middle') = [-1.905; 0.668; 0.538];
radii_map('ring_middle') = 0.2;

centers_map('ring_bottom') = [-2.546; 0.798; 0.184];
radii_map('ring_bottom') = 0.22;

centers_map('ring_base') = [-1.591; 0.873; -0.417];
radii_map('ring_base') = 0.29;

%% Middle
centers_map('middle_top') = [-1.952; 0.112; -0.073];
radii_map('middle_top') = 0.2;

centers_map('middle_middle') = [-2.465; 0.079; 0.123];
radii_map('middle_middle') = 0.21;

centers_map('middle_bottom') = [-2.809; 0.193; -0.489];
radii_map('middle_bottom') = 0.24;

centers_map('middle_base') = [-1.619; 0.411; -0.583];
radii_map('middle_base') = 0.29;

%% Index
centers_map('index_top') = [-1.93; -0.296; -0.099];
radii_map('index_top') = 0.19;

centers_map('index_middle') = [-2.347; -0.445; -0.022];
radii_map('index_middle') = 0.22;

centers_map('index_bottom') = [-2.447; -0.633; -0.451];
radii_map('index_bottom') = 0.27;

centers_map('index_base') = [-1.485; -0.2; -0.495];
radii_map('index_base') = 0.27;

%% Thumb
centers_map('thumb_additional') = [-1.773; -1.633; 0.042];
radii_map('thumb_additional') = 0.13;

centers_map('thumb_top') = [-1.538; -1.505; 0.132];
radii_map('thumb_top') = 0.18;

centers_map('thumb_middle') = [-1.214; -1.395; 0.225];
radii_map('thumb_middle') = 0.2;

centers_map('thumb_bottom') = [-0.734; -0.784; 0.596];
radii_map('thumb_bottom') = 0.3;

centers_map('thumb_base') = [-0.556; 0.315; 0.877];
radii_map('thumb_base') = 0.5;

%% Palm top
centers_map('palm_pinky') = [-1.527; 1.429; -0.004];
radii_map('palm_pinky') = 0.35;

centers_map('palm_ring') = [-1.47; 0.808; -0.163];
radii_map('palm_ring') = 0.35;

centers_map('palm_middle') = [-1.573; 0.319; -0.359];
radii_map('palm_middle') = 0.35;

centers_map('palm_index') = [-1.526; -0.16; -0.407];
radii_map('palm_index') = 0.35;

centers_map('palm_thumb') = [-1.146; -0.302; 0.075];
radii_map('palm_thumb') = 0.2;

%% Palm bottom
centers_map('palm_right') = [-0.442; 1.17; 0.801];
radii_map('palm_right') = 0.59;

centers_map('palm_left') = [];
radii_map('palm_left') = 0.58;

%% Wrist
centers_map('wrist_top_left') = [0.191; 0.718; 1.013];
radii_map('wrist_top_left') = 0.52;

centers_map('wrist_top_right') = [-0.063; 1.205; 0.902];
radii_map('wrist_top_right') = 0.52;

centers_map('wrist_bottom_right') = [1.809; 1.022; 1.631];
radii_map('wrist_bottom_right') = 0.52;

centers_map('wrist_bottom_left') = [1.837; 0.621; 1.621];
radii_map('wrist_bottom_left') = 0.52;

