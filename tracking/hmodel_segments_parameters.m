function [segments] = hmodel_segments_parameters()

segments = {};

i = 0;

%% segment 1
i = i + 1;
segments{i}.name = 'palm_back';
segments{i}.parent_id = [];
segments{i}.children_ids = [2, 5, 8, 11, 14];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6];
segments{i}.local = eye(4, 4);
segments{i}.global = segments{i}.local;
segments{i}.rigid_names = {'palm_index', 'palm_left', 'palm_middle', 'palm_pinky', 'palm_right', 'palm_ring', 'palm_thumb', 'thumb_fold'};


%% segment 2
i = i + 1;
segments{i}.name = 'thumb_base';
segments{i}.parent_id = 1;
segments{i}.children_ids = [3];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8];
segments{i}.rigid_names = {'thumb_membrane'};

%% segment 3
i = i + 1;
segments{i}.name = 'thumb_bottom';
segments{i}.parent_id = 2;
segments{i}.children_ids = [4];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9];

%% segment 4
i = i + 1;
segments{i}.name = 'thumb_middle';
segments{i}.parent_id = 3;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
segments{i}.rigid_names = {'thumb_top', 'thumb_additional'};

%% segment 5
i = i + 1;
segments{i}.name = 'pinky_base';
segments{i}.parent_id = 1;
segments{i}.children_ids = [6];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24];
segments{i}.rigid_names = {'pinky_membrane'};

%% segment 6
i = i + 1;
segments{i}.name = 'pinky_bottom';
segments{i}.parent_id = 5;
segments{i}.children_ids = [7];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24, 25];

%% segment 7
i = i + 1;
segments{i}.name = 'pinky_middle';
segments{i}.parent_id = 6;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24, 25, 26];
segments{i}.rigid_names = {'pinky_top'};

%% segment 8
i = i + 1;
segments{i}.name = 'ring_base';
segments{i}.parent_id = 1;
segments{i}.children_ids = [9];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20];
segments{i}.rigid_names = {'ring_membrane'};

%% segment 9
i = i + 1;
segments{i}.name = 'ring_bottom';
segments{i}.parent_id = 8;
segments{i}.children_ids = [10];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20, 21];

%% segment 10
i = i + 1;
segments{i}.name = 'ring_middle';
segments{i}.parent_id = 9;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20, 21, 22];
segments{i}.rigid_names = {'ring_top'};

%% segment 11
i = i + 1;
segments{i}.name = 'middle_base';
segments{i}.parent_id = 1;
segments{i}.children_ids = [12];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16];
segments{i}.rigid_names = {'middle_membrane'};

%% segment 12
i = i + 1;
segments{i}.name = 'middle_bottom';
segments{i}.parent_id = 11;
segments{i}.children_ids = [13];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16, 17];

%% segment 13
i = i + 1;
segments{i}.name = 'middle_middle';
segments{i}.parent_id = 12;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16, 17, 18];
segments{i}.rigid_names = {'middle_top'};

%% segment 14
i = i + 1;
segments{i}.name = 'index_base';
segments{i}.parent_id = 1;
segments{i}.children_ids = [15];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12];
segments{i}.rigid_names = {'index_membrane'};

%% segment 15
i = i + 1;
segments{i}.name = 'index_bottom';
segments{i}.parent_id = 14;
segments{i}.children_ids = [16];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12, 13];

%% segment 16
i = i + 1;
segments{i}.name = 'index_middle';
segments{i}.parent_id = 15;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12, 13, 14];
segments{i}.rigid_names = {'index_top'};
