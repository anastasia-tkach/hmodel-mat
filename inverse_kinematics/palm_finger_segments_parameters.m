function [segments] = palm_finger_segments_parameters()

segments = {};

i = 0;

%% Segment 1
i = i + 1;
segment.name = 'Palm';
segment.parent_id = 0;
segment.children_ids = [2];
segment.kinematic_chain = [1, 2, 3, 4, 5, 6];
segment.local = [
    1 0 0 0;
    0 1 0 0;
    0 0 1 0;
    0 0 0 1;
    ];
segment.global = segment.local;
segment.radius1 = 36;
segment.radius2 = 36;
segment.ratio = 0.3;
segment.length = 71.324;
segments{i} = segment;

%% Segment 2
i = i + 1;
segment.name = 'HandPinky1';
segment.parent_id = 1;
segment.children_ids = [3];
segment.kinematic_chain = [1, 2, 3, 4, 5, 6];
segment.local = [
%     1 0 0 -30;
%     0 1 0 80;
%     0 0 1 0;
%     0 0 0 1;
%     ];
  0.893272  -0.449347   0.012365        -30;
  0.449458   0.892369 -0.0408043         80;
0.00730108  0.0420069   0.999091          0;
         0          0          0          1;
];
segment.radius1 = 8;
segment.radius2 = 7.2;
segment.ratio = 1;
segment.length = 30;
segments{i} = segment;

%% Segment 3
i = i + 1;
segment.name = 'HandPinky2';
segment.parent_id = 2;
segment.children_ids = [4];
segment.kinematic_chain = [1, 2, 3, 4, 5, 6, 7];
segment.local = [
%     1 0 0 0;
%     0 1 0 30;
%     0 0 1 0;
%     0 0 0 1;
%     ];
   0.998445   0.0555928 -0.00418428           0;
 -0.0556588    0.998291  -0.0177942          30;
 0.00318789   0.0179994    0.999833           0;
          0           0           0           1;
];
segment.radius1 = 7.2;
segment.radius2 = 6.4;
segment.ratio = 1;
segment.length = 18;
segments{i} = segment;

%% Segment 4
i = i + 1;
segment.name = 'HandPinky3';
segment.parent_id = 3;
segment.children_ids = [];
segment.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8];
segment.local = [
%     1 0 0 0;
%     0 1 0 18;
%     0 0 1 0;
%     0 0 0 1;
%     ];
    0.999998   0.00198716 -3.71401e-05            0;
  -0.0019819     0.998406    0.0564048           18;
 0.000149167   -0.0564046     0.998408            0;
           0            0            0            1;
];
segment.radius1 = 6.4;
segment.radius2 = 6.4;
segment.ratio = 1;
segment.length = 12;
segments{i} = segment;




