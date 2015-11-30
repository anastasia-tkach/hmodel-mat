
filename = [data_path, 'pose', num2str(pose_id), '.obj'];
centers_map = containers.Map();
radii_map = containers.Map();

%% Pinky
centers_map('pinky_top') = [1.944; 2.903; -3.746];
radii_map('pinky_top') = 0.15;

centers_map('pinky_middle') = [1.941; 2.648; -3.478];
radii_map('pinky_middle') = 0.16;

centers_map('pinky_bottom') = [1.836; 2.15; -3.081];
radii_map('pinky_bottom') = 0.2;

centers_map('pinky_base') = [1.653; 1.194; -2.355];
radii_map('pinky_base') = 0.35;

%% Ring
centers_map('ring_top') = [0.415; 3.453; -3.646];
radii_map('ring_top') = 0.16;

centers_map('ring_middle') = [0.579; 3.125; -3.414];
radii_map('ring_middle') = 0.17;

centers_map('ring_bottom') = [0.75; 2.502; -3.076];
radii_map('ring_bottom') = 0.22;

centers_map('ring_base') = [1.098; 1.237; -2.267];
radii_map('ring_base') = 0.4;

%% Middle
centers_map('middle_top') = [-0.827; 3.278; -3.583];
radii_map('middle_top') = 0.2;

centers_map('middle_middle') = [-0.48; 2.767; -3.201];
radii_map('middle_middle') = 0.21;
 
centers_map('middle_bottom') = [-0.187; 2.281; -2.93];
radii_map('middle_bottom') = 0.27;

centers_map('middle_base') = [0.669; 1.25; -2.087];
radii_map('middle_base') = 0.45;

%% Index
centers_map('index_top') = [-1.518; 2.972; -2.435];
radii_map('index_top') = 0.18;

centers_map('index_middle') = [-1.135; 2.595; -2.239];
radii_map('index_middle') = 0.2;

centers_map('index_bottom') = [-0.756; 2.214; -2.072];
radii_map('index_bottom') = 0.27;

centers_map('index_base') = [0.235; 1.388; -1.739];
radii_map('index_base') = 0.43;

%% Thumb
centers_map('thumb_top') = [-0.96; 0.972; 0.624];
radii_map('thumb_top') = 0.2;

centers_map('thumb_middle') = [-0.3; 0.856; 0.172];
radii_map('thumb_middle') = 0.26;

centers_map('thumb_bottom') = [0.186; 0.633; -0.226];
radii_map('thumb_bottom') = 0.34;

centers_map('thumb_base') = [0.979; 0.077; -0.819];
radii_map('thumb_base') = 0.5;

%% Palm
centers_map('palm_left') = [1.158; -0.272; -1.03];
radii_map('palm_left') = 0.5;

centers_map('palm_right') = [1.66; -0.255; -1.539];
radii_map('palm_right') = 0.59;

%% Wrist
centers_map('wrist_top_left') = [1.448; -1.02; -1.03];
radii_map('wrist_top_left') = 0.55;

centers_map('wrist_top_right') = [1.771; -1.045; -1.248];
radii_map('wrist_top_right') = 0.55;

centers_map('wrist_bottom_left') = [1.89; -1.948; -0.377];
radii_map('wrist_bottom_left') = 0.55;

centers_map('wrist_bottom_right') = [2.263; -1.923; -0.639];
radii_map('wrist_bottom_right') = 0.55;


