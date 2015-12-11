close all;
centers_map = containers.Map();
radii_map = containers.Map();

%% Pinky
centers_map('pinky_top') = [0.99; 2.97; -1.29];
radii_map('pinky_top') = 0.14;

centers_map('pinky_middle') = [0.852; 2.583; -1.378];
radii_map('pinky_middle') = 0.16;

centers_map('pinky_bottom') = [0.603; 2.02; -1.489];
radii_map('pinky_bottom') = 0.2;

centers_map('pinky_base') = [0.151; 1.098; -1.417];
radii_map('pinky_base') = 0.22;

%% Ring
centers_map('ring_top') = [0.24; 3.63; -0.8];
radii_map('ring_top') = 0.17;

centers_map('ring_middle') = [0.132; 3.143; -0.993];
radii_map('ring_middle') = 0.19;

centers_map('ring_bottom') = [-0.056; 2.406; -1.284];
radii_map('ring_bottom') = 0.24;

centers_map('ring_base') = [-0.365; 1.18; -1.342];
radii_map('ring_base') = 0.24;

%% Middle
centers_map('middle_top') = [-0.361; 3.967; -0.664];
radii_map('middle_top') = 0.18;

centers_map('middle_middle') = [-0.502; 3.455; -0.874];
radii_map('middle_middle') = 0.2;

centers_map('middle_bottom') = [-0.713; 2.723; -1.16];
radii_map('middle_bottom') = 0.26;

centers_map('middle_base') = [-0.771; 1.33; -1.244];
radii_map('middle_base') = 0.27;

%% Index
centers_map('index_top') = [-0.972; 3.704; -0.391];
radii_map('index_top') = 0.16;

centers_map('index_middle') = [-1.107; 3.273; -0.588];
radii_map('index_middle') = 0.18;

centers_map('index_bottom') = [-1.289; 2.637; -0.844];
radii_map('index_bottom') = 0.25;

centers_map('index_base') = [-1.225; 1.432; -0.909];
radii_map('index_base') = 0.27;

%% Thumb
centers_map('thumb_fold') = [-1.433; 0.711; 0.074];
radii_map('thumb_fold') = 0.2;

centers_map('thumb_additional') = [-1.809; 2.039; 0.676];
radii_map('thumb_additional') = 0.16;

centers_map('thumb_top') = [-1.788; 1.848; 0.649];
radii_map('thumb_top') = 0.2;

centers_map('thumb_middle') = [-1.874; 1.389; 0.543];
radii_map('thumb_middle') = 0.25;

centers_map('thumb_bottom') = [-1.585; 0.568; 0.313];
radii_map('thumb_bottom') = 0.35;

centers_map('thumb_base') = [-0.776; -0.094; -0.061];
radii_map('thumb_base') = 0.5;

%% Palm top
centers_map('palm_pinky') = [0.232; 1.214; -1.298];
radii_map('palm_pinky') = 0.31;

centers_map('palm_ring') = [-0.262; 1.422; -1.188];
radii_map('palm_ring') = 0.31;

centers_map('palm_middle') = [-0.668; 1.496; -1.068];
radii_map('palm_middle') = 0.31;

centers_map('palm_index') = [-1.154; 1.571; -0.764];
radii_map('palm_index') = 0.31;

centers_map('palm_thumb') = [-1.219; 1.12; -0.616];
radii_map('palm_thumb') = 0.3;

%% Palm bottom
centers_map('palm_right') = [-0.133; -0.378; -0.609];
radii_map('palm_right') = 0.57;

centers_map('palm_left') = [];
radii_map('palm_left') = 0;

%% Wrist
centers_map('wrist_top_left') = [-0.685; -0.915; -0.348];
radii_map('wrist_top_left') = 0.53;

centers_map('wrist_top_right') = [-0.308; -0.988; -0.584];
radii_map('wrist_top_right') = 0.53;

centers_map('wrist_bottom_right') = [-0.498; -1.948; -0.364];
radii_map('wrist_bottom_right') = 0.53;

centers_map('wrist_bottom_left') = [-0.851; -1.83; -0.225];
radii_map('wrist_bottom_left') = 0.53;

