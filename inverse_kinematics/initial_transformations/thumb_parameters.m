function [phalanges, dofs] = thumb_parameters()

%% Phalanges
phalanges = cell(6, 1);
% % Hand
% phalanges{1}.local = [...
%     1         0         0 -0.597578
%     0         1         0   12.2038
%     0         0         1  -2.58477
%     0         0         0         1];
% phalanges{1}.parent_id = 6;
% phalanges{1}.children_ids = [2];
% phalanges{1}.length = 13.2327;
% % Thumb1
% phalanges{2}.local = ...
%     [0.353999  0.922935  0.151249   11.2015
% -0.922935  0.318587  0.216088  0.920158
%  0.151249 -0.216088  0.964588  -6.98464
%         0         0         0         1];
% phalanges{2}.parent_id = 1;
% phalanges{2}.children_ids = [3];
% phalanges{2}.length = 29.2982;
% % Thumb2
% phalanges{3}.local = [...
%     0.854949     -0.427578      0.293664 -1.77636e-015
%      0.427126      0.901543     0.0691577       29.2982
%     -0.294321      0.066305      0.953404  1.33227e-015
%             0             0             0             1];
% phalanges{3}.parent_id = 2;
% phalanges{3}.children_ids = [4];
% phalanges{3}.length = 21.2620;
% % Thumb3
% phalanges{4}.local = [...
%     0.961957  -0.272905 -0.0127175   0.416739
%   0.259639   0.927698  -0.268261    20.4192
%  0.0850077   0.254754   0.963262   -5.91231
%          0          0          0          1];
% phalanges{4}.parent_id = 3;
% phalanges{4}.children_ids = [];
% phalanges{4}.length = 12.4189;

% segment 1
i = 1;
phalanges{i}.name = 'Hand';
phalanges{i}.parent_id = 6;
phalanges{i}.children_ids = [2];
phalanges{i}.kinematic_chain = [1, 2, 3, 4, 5, 6];
phalanges{i}.local = [
1 0 0 0;
0 1 0 0;
0 0 1 0;
0 0 0 1;
];
phalanges{i}.global = phalanges{i}.local;
phalanges{i}.radius1 = 36;
phalanges{i}.radius2 = 36;
phalanges{i}.ratio = 0.3;
phalanges{i}.length = 71.324;

% segment 2
i = i + 1;
phalanges{i}.name = 'HandThumb1';
phalanges{i}.parent_id = 1;
phalanges{i}.children_ids = [3];
phalanges{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8];
phalanges{i}.local = [
  0.479004   0.717332   0.505954         20;
 -0.569837   0.692528  -0.442368         10;
 -0.667712 -0.0764155   0.740486        -10;
         0          0          0          1;
];
phalanges{i}.radius1 = 13.6;
phalanges{i}.radius2 = 8;
phalanges{i}.ratio = 1;
phalanges{i}.length = 40;

% segment 3
i = i + 1;
phalanges{i}.name = 'HandThumb2';
phalanges{i}.parent_id = 2;
phalanges{i}.children_ids = [4];
phalanges{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9];
phalanges{i}.local = [
  0.996067  0.0781009 -0.0418357          0;
 -0.067936   0.976356   0.205217         40;
 0.0568741  -0.201568   0.977822          0;
         0          0          0          1;
];
phalanges{i}.radius1 = 8;
phalanges{i}.radius2 = 7.2;
phalanges{i}.ratio = 1;
phalanges{i}.length = 24;

% segment 4
i = i + 1;
phalanges{i}.name = 'HandThumb3';
phalanges{i}.parent_id = 3;
phalanges{i}.children_ids = [];
phalanges{i}.kinematic_chain = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
phalanges{i}.local = [
     0.99863  3.44945e-17    0.0523263            0;
-3.03013e-17            1 -8.09289e-17           24;
  -0.0523263  7.92325e-17      0.99863            0;
           0            0            0            1;
];
phalanges{i}.radius1 = 7.2;
phalanges{i}.radius2 = 6.4;
phalanges{i}.ratio = 1;
phalanges{i}.length = 16;

% Pose
phalanges{5}.local = [...
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1];
phalanges{5}.children_ids = [6];
phalanges{5}.parent_id = -1;

% Scale
phalanges{6}.local = [...
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1];
phalanges{6}.children_ids = [1];
phalanges{6}.parent_id = 5;

%% Dofs
% 0
index = 1;
dofs = cell(13, 1);
dofs{index}.axis = [1 0 0];
dofs{index}.type = 1;
dofs{index}.phalange_id = 5;
index = index + 1;

% 1
dofs{index}.axis = [0 1 0];
dofs{index}.type = 1;
dofs{index}.phalange_id = 5;
index = index + 1;

% 2
dofs{index}.axis = [0 0 1];
dofs{index}.type = 1;
dofs{index}.phalange_id = 5;
index = index + 1;

% 3
dofs{index}.axis = [1 0 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 5;
index = index + 1;

% 4
dofs{index}.axis = [0 1 0];
dofs{index}.type = 0;
dofs{index}.phalange_id = 5;
index = index + 1;

% 5
dofs{index}.axis = [0 0 1];
dofs{index}.type = 0;
dofs{index}.phalange_id = 5;
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
