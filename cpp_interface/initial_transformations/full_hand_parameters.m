function [phalanges, dofs] = full_hand_parameters()

%% Phalanges
phalanges = cell(18, 1);

% Hand
i = 1;
phalanges{i}.name = 'palm_back';
phalanges{i}.parent_id = 18;
phalanges{i}.children_ids = [2, 5, 8, 11, 14];
phalanges{i}.local = [
1 0 0 0;
0 1 0 0;
0 0 1 0;
0 0 0 1;
];
phalanges{i}.global = phalanges{i}.local;
phalanges{i}.rigid_names = {'palm_index', 'palm_left', 'palm_middle', 'palm_pinky', 'palm_right', 'palm_ring', 'palm_thumb', 'thumb_fold'};

% HandThumb1
i = i + 1;
phalanges{i}.name = 'thumb_base';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [3];
%phalanges{i}.rigid_names = {'thumb_membrane'};

% HandThumb2
i = i + 1;
phalanges{i}.name = 'thumb_bottom';
phalanges{i}.parent_id = 2;
phalanges{i}.children_ids = [4];

% HandThumb3
i = i + 1;
phalanges{i}.name = 'thumb_middle';
phalanges{i}.parent_id = 3;
phalanges{i}.children_ids = [];
phalanges{i}.rigid_names = {'thumb_top', 'thumb_additional'};

% HandPinky1
i = i + 1;
phalanges{i}.name = 'pinky_base';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [6];
phalanges{i}.rigid_names = {'pinky_membrane'};

% HandPinky2
i = i + 1;
phalanges{i}.name = 'pinky_bottom';
phalanges{i}.parent_id = 5;
phalanges{i}.children_ids = [7];

% HandPinky3
i = i + 1;
phalanges{i}.name = 'pinky_middle';
phalanges{i}.parent_id = 6;
phalanges{i}.children_ids = [];
phalanges{i}.rigid_names = {'pinky_top'};

% HandRing1
i = i + 1;
phalanges{i}.name = 'ring_base';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [9];
phalanges{i}.rigid_names = {'ring_membrane'};

% HandRing2
i = i + 1;
phalanges{i}.name = 'ring_bottom';
phalanges{i}.parent_id = 8;
phalanges{i}.children_ids = [10];

% HandRing3
i = i + 1;
phalanges{i}.name = 'ring_middle';
phalanges{i}.parent_id = 9;
phalanges{i}.children_ids = [];
phalanges{i}.rigid_names = {'ring_top'};

% HandMiddle1
i = i + 1;
phalanges{i}.name = 'middle_base';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [12];
phalanges{i}.rigid_names = {'middle_membrane'};

% HandMiddle2
i = i + 1;
phalanges{i}.name = 'middle_bottom';
phalanges{i}.parent_id = 11;
phalanges{i}.children_ids = [13];

% HandMiddle3
i = i + 1;
phalanges{i}.name = 'middle_middle';
phalanges{i}.parent_id = 12;
phalanges{i}.children_ids = [];
phalanges{i}.rigid_names = {'middle_top'};

% HandIndex1
i = i + 1;
phalanges{i}.name = 'index_base';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [15];
phalanges{i}.rigid_names = {'index_membrane'};

% HandIndex2
i = i + 1;
phalanges{i}.name = 'index_bottom';
phalanges{i}.parent_id = 14;
phalanges{i}.children_ids = [16];

% HandIndex3
i = i + 1;
phalanges{i}.name = 'index_middle';
phalanges{i}.parent_id = 15;
phalanges{i}.children_ids = [];
phalanges{i}.rigid_names = {'index_top'};

% Pose
i = i + 1;
phalanges{i}.name = 'Pose';
phalanges{i}.parent_id = -1;
phalanges{i}.children_ids = [18];
phalanges{i}.local = [...
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1];

% Scale
i = i + 1;
phalanges{i}.name = 'Scale';
phalanges{i}.parent_id = 17;
phalanges{i}.children_ids = [1];
phalanges{i}.local = [...
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1];

%% Dofs
% 0
index = 1;
dofs = cell(13, 1);
dofs{index}.axis = [1 0 0];
dofs{index}.type = 1;
dofs{index}.phalange_id = 17;
index = index + 1;

% 1
dofs{index}.axis = [0 1 0];
dofs{index}.type = 1;
dofs{index}.phalange_id = 17;
index = index + 1;

% 2
dofs{index}.axis = [0 0 1];
dofs{index}.type = 1;
dofs{index}.phalange_id = 17;
index = index + 1;

% 3
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 17;
index = index + 1;

% 4
dofs{index}.axis = [0 1 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 17;
index = index + 1;

% 5
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 17;
index = index + 1;

% 6
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id =  -1;
index = index + 1;

% 7
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id =  -1;
index = index + 1;

% 8
dofs{index}.axis = [0 1 0];
dofs{index}.type = 0;
dofs{index}.phalange_id =  -1;
index = index + 1;

% 9
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 2;
index = index + 1;

% 10
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 2;
index = index + 1;

% 11
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 3;
index = index + 1;

% 12
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 4;
index = index + 1;

% 13
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 14;
index = index + 1;

% 14
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 14;
index = index + 1;

% 15
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 15;
index = index + 1;

% 16
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 16;
index = index + 1;

% 17
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 11;
index = index + 1;

% 18
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 11;
index = index + 1;

% 19
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 12;
index = index + 1;

% 20
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 13;
index = index + 1;

% 21
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 8;
index = index + 1;

% 22
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 8;
index = index + 1;

% 23
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 9;
index = index + 1;

% 24
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 10;
index = index + 1;

% 25
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 5;
index = index + 1;

% 26
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 5;
index = index + 1;

% 27
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 6;
index = index + 1;

% 28
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 7;
index = index + 1;
