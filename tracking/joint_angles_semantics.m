fingers_map = containers.Map();

%% Pinky
finger.indices = [1, 2, 3, 4];
finger.base_abduction = {'pinky_base', 'pinky_bottom'};
finger.base_flexion = {'pinky_base', 'pinky_bottom'};
finger.bottom_flexion  = {'pinky_base', 'pinky_bottom', 'pinky_middle'};
finger.middle_flexion = {'pinky_bottom', 'pinky_middle', 'pinky_top'};

finger.base_abduction_dof = 23;
finger.base_flexion_dof = 24;
finger.bottom_flexion_dof  = 25;
finger.middle_flexion_dof = 26;

fingers_map('pinky') = finger;

%% Ring
finger.indices = [5, 6, 7, 8];

finger.base_abduction = {'ring_base', 'ring_bottom'};
finger.base_flexion = {'ring_base', 'ring_bottom'};
finger.bottom_flexion = {'ring_base', 'ring_bottom', 'ring_middle'};
finger.middle_flexion = {'ring_bottom', 'ring_middle', 'ring_top'};

finger.base_abduction_dof = 19;
finger.base_flexion_dof = 20;
finger.bottom_flexion_dof = 21;
finger.middle_flexion_dof = 22;

fingers_map('ring') = finger;

%% Middle

finger.indices = [9, 10, 11, 12];

finger.base_abduction = {'middle_base', 'middle_bottom'};
finger.base_flexion = {'middle_base', 'middle_bottom'};
finger.bottom_flexion = {'middle_base', 'middle_bottom', 'middle_middle'};
finger.middle_flexion = {'middle_bottom', 'middle_middle', 'middle_top'};

finger.base_abduction_dof = 15;
finger.base_flexion_dof = 16;
finger.bottom_flexion_dof = 17;
finger.middle_flexion_dof = 18;

fingers_map('middle') = finger;

%% Index

finger.indices = [13, 14, 15, 16];

finger.base_abduction = {'index_base', 'index_bottom'};
finger.base_flexion = {'index_base', 'index_bottom'};
finger.bottom_flexion = {'index_base', 'index_bottom', 'index_middle'};
finger.middle_flexion = {'index_bottom', 'index_middle', 'index_top'};

finger.base_abduction_dof = 11;
finger.base_flexion_dof = 12;
finger.bottom_flexion_dof = 13;
finger.middle_flexion_dof = 14;

fingers_map('index') = finger;

finger_names = {'pinky', 'ring', 'middle', 'index'};