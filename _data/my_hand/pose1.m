filename = [data_path, 'pose', num2str(pose_id), '.obj'];
centers_map = containers.Map();
radii_map = containers.Map();

%% Pinky
centers_map('pinky_top') = [0.706; 2.57; -0.186];
radii_map('pinky_top') = 0.18;

centers_map('pinky_middle') = [0.71; 2.449; -0.689];
radii_map('pinky_middle') = 0.2;

centers_map('pinky_bottom') = [0.702; 1.933; -0.965];
radii_map('pinky_bottom') = 0.25;

centers_map('pinky_base') = [0.689; 1.019; -0.59];
radii_map('pinky_base') = 0.38;

%% Ring
centers_map('ring_top') = [0.083; 2.903; 0.139];
radii_map('ring_top') = 0.18;

centers_map('ring_middle') = [-0.067; 2.699; -0.415];
radii_map('ring_middle') = 0.22;

centers_map('ring_bottom') = [-0.158; 2.163; -0.908];
radii_map('ring_bottom') = 0.28;

centers_map('ring_base') = [0.155; 1.04; -0.481];
radii_map('ring_base') = 0.41;

%% Middle
centers_map('middle_top') = [-0.434; 2.951; 0.332];
radii_map('middle_top') = 0.2;

centers_map('middle_middle') = [-0.645; 2.837; -0.237];
radii_map('middle_middle') = 0.23;

centers_map('middle_bottom') = [-0.804; 2.309; -0.762];
radii_map('middle_bottom') = 0.29;

centers_map('middle_base') = [-0.355; 1.043; -0.38];
radii_map('middle_base') = 0.43;

%% Index
centers_map('index_top') = [-0.879; 3.044; 0.668];
radii_map('index_top') = 0.2;

centers_map('index_middle') = [-1.214; 2.827; 0.27];
radii_map('index_middle') = 0.23;

centers_map('index_bottom') = [-1.387; 2.264; -0.082];
radii_map('index_bottom') = 0.28;

centers_map('index_base') = [-0.753; 1.067; -0.072];
radii_map('index_base') = 0.43;

%% Thumb
centers_map('thumb_top') = [-0.258; 2.927; 0.821];
radii_map('thumb_top') = 0.2;

centers_map('thumb_middle') = [-0.317; 2.232; 0.989];
radii_map('thumb_middle') = 0.27;

centers_map('thumb_bottom') = [-0.18; 1.242; 0.997];
radii_map('thumb_bottom') = 0.4;

centers_map('thumb_base') = [0.074; 0.528; 0.991];
radii_map('thumb_base') = 0.52;

%% Palm
centers_map('palm_left') = [0.251; 0.095; 0.853];
radii_map('palm_left') = 0.62;

centers_map('palm_right') = [0.779; 0.021; 0.647];
radii_map('palm_right') = 0.62;

%% Wrist
centers_map('wrist_top_left') = [0.553; -0.655; 1.167];
radii_map('wrist_top_left') = 0.55;

centers_map('wrist_top_right') = [0.985; -0.63; 0.958];
radii_map('wrist_top_right') = 0.55;

centers_map('wrist_bottom_left') = [0.902; -1.125; 1.641];
radii_map('wrist_bottom_left') = 0.55;

centers_map('wrist_bottom_right') = [1.251; -1.031; 1.472];
radii_map('wrist_bottom_right') = 0.55;


