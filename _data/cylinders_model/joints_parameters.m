function [theta] = joints_parameters(t)

i = 0;

%% 1: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 1;

%% 2: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = [0; 1; 0];
theta{i}.segment_id = 1;

%% 3: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 1;

%% 4: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 1;

%% 5: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 1; 0];
theta{i}.segment_id = 1;

%% 6: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 1;

%% 7: Thumb1 abduction (6)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 2;

%% 8: Thumb1 flexion (8)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 2;

%% 9: Thumb2 flexion (8)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 3;

%% 10: Thumb3 flexion (9)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 4;

%% 11: Index1 abduction (10)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 14;

%% 12: Index1 flexion (11)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 14;

%% 13: Index2 flexion (12)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 15;

%% 14: Index3 flexion (13)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 16;

%% 15: Middle1 abduction (14)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 11;

%% 16: Middle1 flexion (15)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 11;

%% 17: Middle2 flexion (16)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 12;

%% 18: Middle3 flexion (17)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 13;

%% 19: Ring1 abduction (18)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 8;

%% 20: Ring1 flexion (19)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 8;

%% 21: Ring2 flexion (20)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 9;

%% 22: Ring3 flexion (21)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 10;

%% 23: Pinky1 abduction (22)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [0; 0; 1];
theta{i}.segment_id = 5;

%% 24: Pinky1 flexion (23)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 5;

%% 25: Pinky2 flexion (24)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 6;

%% 26: Pinky3 flexion (25)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 7;

% %% 27: Pinky2 abduction 
% i = i + 1;
% theta{i}.value = t(i);
% theta{i}.type = 'R';
% theta{i}.axis = [0; 0; 1];
% theta{i}.segment_id = 6;
% 
% %% 28: Pinky3 abduction 
% i = i + 1;
% theta{i}.value = t(i);
% theta{i}.type = 'R';
% theta{i}.axis = [0; 0; 1];
% theta{i}.segment_id = 7;



