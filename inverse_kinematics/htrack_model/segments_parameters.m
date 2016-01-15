function [segments] = segments_parameters()

segments = {};

i = 0;

%% segment 1
i = i + 1;
segments{i}.name = 'Hand';
segments{i}.parent_id = [];
segments{i}.children_ids = [2, 5, 8, 11, 14];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6];
segments{i}.local = [
1 0 0 0;
0 1 0 0;
0 0 1 0;
0 0 0 1;
];
segments{i}.global = segments{i}.local;
segments{i}.radius1 = 36;
segments{i}.radius2 = 36;
segments{i}.ratio = 0.3;
segments{i}.length = 71.324;

%% segment 2
i = i + 1;
segments{i}.name = 'HandThumb1';
segments{i}.parent_id = 1;
segments{i}.children_ids = [3];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8];
segments{i}.local = [
  0.479004   0.717332   0.505954         20;
 -0.569837   0.692528  -0.442368         10;
 -0.667712 -0.0764155   0.740486        -10;
         0          0          0          1;
];
segments{i}.radius1 = 13.6;
segments{i}.radius2 = 8;
segments{i}.ratio = 1;
segments{i}.length = 40;

%% segment 3
i = i + 1;
segments{i}.name = 'HandThumb2';
segments{i}.parent_id = 2;
segments{i}.children_ids = [4];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9];
segments{i}.local = [
  0.996067  0.0781009 -0.0418357          0;
 -0.067936   0.976356   0.205217         40;
 0.0568741  -0.201568   0.977822          0;
         0          0          0          1;
];
segments{i}.radius1 = 8;
segments{i}.radius2 = 7.2;
segments{i}.ratio = 1;
segments{i}.length = 24;

%% segment 4
i = i + 1;
segments{i}.name = 'HandThumb3';
segments{i}.end_name = 'HandThumb4';
segments{i}.parent_id = 3;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
segments{i}.local = [
     0.99863  3.44945e-17    0.0523263            0;
-3.03013e-17            1 -8.09289e-17           24;
  -0.0523263  7.92325e-17      0.99863            0;
           0            0            0            1;
];
segments{i}.radius1 = 7.2;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 16;

%% segment 5
i = i + 1;
segments{i}.name = 'HandPinky1';
segments{i}.parent_id = 1;
segments{i}.children_ids = [6];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24];
segments{i}.local = [
  0.893272  -0.449347   0.012365        -30;
  0.449458   0.892369 -0.0408043         80;
0.00730108  0.0420069   0.999091          0;
         0          0          0          1;
];
segments{i}.radius1 = 8;
segments{i}.radius2 = 7.2;
segments{i}.ratio = 1;
segments{i}.length = 30;

%% segment 6
i = i + 1;
segments{i}.name = 'HandPinky2';
segments{i}.parent_id = 5;
segments{i}.children_ids = [7];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24, 25];
segments{i}.local = [
   0.998445   0.0555928 -0.00418428           0;
 -0.0556588    0.998291  -0.0177942          30;
 0.00318789   0.0179994    0.999833           0;
          0           0           0           1;
];
segments{i}.radius1 = 7.2;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 18;

%% segment 7
i = i + 1;
segments{i}.name = 'HandPinky3';
segments{i}.end_name = 'HandPinky4';
segments{i}.parent_id = 6;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 23, 24, 25, 26];
segments{i}.local = [
    0.999998   0.00198716 -3.71401e-05            0;
  -0.0019819     0.998406    0.0564048           18;
 0.000149167   -0.0564046     0.998408            0;
           0            0            0            1;
];
segments{i}.radius1 = 6.4;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 12;

%% segment 8
i = i + 1;
segments{i}.name = 'HandRing1';
segments{i}.parent_id = 1;
segments{i}.children_ids = [9];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20];
segments{i}.local = [
  0.974736  -0.222472 -0.0199051        -10;
  0.223103   0.974016  0.0389697         80;
 0.0107182 -0.0424261   0.999042          0;
         0          0          0          1;
];
segments{i}.radius1 = 8;
segments{i}.radius2 = 7.2;
segments{i}.ratio = 1;
segments{i}.length = 38;

%% segment 9
i = i + 1;
segments{i}.name = 'HandRing2';
segments{i}.parent_id = 8;
segments{i}.children_ids = [10];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20, 21];
segments{i}.local = [
    0.999995  -0.00326932 -0.000170183            0;
  0.00327233      0.99974    0.0225703           38;
 9.63464e-05   -0.0225708     0.999745            0;
           0            0            0            1;
];
segments{i}.radius1 = 7.2;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 22.8;

%% segment 10
i = i + 1;
segments{i}.name = 'HandRing3';
segments{i}.end_name = 'HandRing4';
segments{i}.parent_id = 9;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 19, 20, 21, 22];
segments{i}.local = [
   0.999165  -0.0407941 -0.00224546           0;
  0.0408006    0.999163  0.00293311        22.8;
 0.00212393 -0.00302228    0.999993           0;
          0           0           0           1;
];
segments{i}.radius1 = 6.4;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 15.2;

%% segment 11
i = i + 1;
segments{i}.name = 'HandMiddle1';
segments{i}.parent_id = 1;
segments{i}.children_ids = [12];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16];
segments{i}.local = [
  0.999545 -0.0244035 -0.0177468         10;
 0.0271988   0.983341   0.179722         80;
 0.0130653  -0.180123   0.983557          0;
         0          0          0          1;
];
segments{i}.radius1 = 8;
segments{i}.radius2 = 7.2;
segments{i}.ratio = 1;
segments{i}.length = 40;

%% segment 12
i = i + 1;
segments{i}.name = 'HandMiddle2';
segments{i}.parent_id = 11;
segments{i}.children_ids = [13];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16, 17];
segments{i}.local = [
           1 -0.000114317 -5.92047e-06            0;
 0.000112811     0.992959    -0.118458           40;
 1.94206e-05     0.118458     0.992959            0;
           0            0            0            1;
];
segments{i}.radius1 = 7.2;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 24;

%% segment 13
i = i + 1;
segments{i}.name = 'HandMiddle3';
segments{i}.end_name = 'HandMiddle4';
segments{i}.parent_id = 12;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 15, 16, 17, 18];
segments{i}.local = [
 1  0  0  0;
 0  1  0 24;
 0  0  1  0;
 0  0  0  1;
];
segments{i}.radius1 = 6.4;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 16;

%% segment 14
i = i + 1;
segments{i}.name = 'HandIndex1';
segments{i}.parent_id = 1;
segments{i}.children_ids = [15];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12];
segments{i}.local = [
   0.985431    0.170074 0.000888117          30;
  -0.169422    0.981171   0.0927368          80;
  0.0149007  -0.0915362     0.99569           0;
          0           0           0           1;
];
segments{i}.radius1 = 8;
segments{i}.radius2 = 7.2;
segments{i}.ratio = 1;
segments{i}.length = 38;

%% segment 15
i = i + 1;
segments{i}.name = 'HandIndex2';
segments{i}.parent_id = 14;
segments{i}.children_ids = [16];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12, 13];
segments{i}.local = [
    0.999472   -0.0325009 -0.000360672            0;
   0.0323889     0.996832   -0.0726397           38;
  0.00272039    0.0725897     0.997358            0;
           0            0            0            1;
];
segments{i}.radius1 = 7.2;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 22.8;

%% segment 16
i = i + 1;
segments{i}.name = 'HandIndex3';
segments{i}.end_name = 'HandIndex4';
segments{i}.parent_id = 15;
segments{i}.children_ids = [];
segments{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 11, 12, 13, 14];
segments{i}.local = [
   1    0    0    0;
   0    1    0 22.8;
   0    0    1    0;
   0    0    0    1;
];
segments{i}.radius1 = 6.4;
segments{i}.radius2 = 6.4;
segments{i}.ratio = 1;
segments{i}.length = 15.2;


