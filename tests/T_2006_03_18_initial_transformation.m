% l1 = rand();
% l2 = rand();
% l3 = rand();
% alpha = randn(3, 1);
% theta = randn(4, 1);
clear; clc;

%% Phalanges
phalanges = cell(5, 1);
% Hand
phalanges{1}.local = [...
    1         0         0 -0.597578
    0         1         0   12.2038
    0         0         1  -2.58477
    0         0         0         1];
phalanges{1}.parent_id = 6;
phalanges{1}.children_ids = [2];
% Thumb1
phalanges{2}.local = ...
    [0.353999  0.922935  0.151249   11.2015
-0.922935  0.318587  0.216088  0.920158
 0.151249 -0.216088  0.964588  -6.98464
        0         0         0         1];
phalanges{2}.parent_id = 1;
phalanges{2}.children_ids = [3];
% Thumb2
phalanges{3}.local = [...
    0.854949     -0.427578      0.293664 -1.77636e-015
     0.427126      0.901543     0.0691577       29.2982
    -0.294321      0.066305      0.953404  1.33227e-015
            0             0             0             1];
phalanges{3}.parent_id = 2;
phalanges{3}.children_ids = [4];
% Thumb3
phalanges{4}.local = [...
    0.961957  -0.272905 -0.0127175   0.416739
  0.259639   0.927698  -0.268261    20.4192
 0.0850077   0.254754   0.963262   -5.91231
         0          0          0          1];
phalanges{4}.parent_id = 3;
phalanges{4}.children_ids = [];

phalanges{5}.local = [...
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1];
phalanges{5}.children_ids = [6];
phalanges{5}.parent_id = -1;

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

theta = [0, -70, 400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
theta(5) = 1;
theta(10) = 0.5;
theta(11) = 0.3;
theta(12) = 1;
theta(13) = 0.5;
phalanges = htrack_move(theta, dofs, phalanges);

for i = 1:length(phalanges)
    disp(i);    
    disp('global  = ');
    disp(phalanges{i}.global);
end













