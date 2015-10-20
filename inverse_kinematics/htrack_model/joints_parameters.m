function [theta] =  joints_parameters(t)

i = 0;

%% 1: Thumb1 abduction (6)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'Z';
theta{i}.segment_id = 2;

%% 2: Thumb1 flexion (7)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 2;

%% 3: Thumb2 flexion (8)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 3;

%% 4: Thumb3 flexion (9)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 4;

%% 5: Index1 abduction (10)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'Z';
theta{i}.segment_id = 14;

%% 6: Index1 flexion (11)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 14;

%% 7: Index2 flexion (12)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 15;

%% 8: Index3 flexion (13)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 16;

%% 9: Middle1 abduction (14)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'Z';
theta{i}.segment_id = 11;

%% 10: Middle1 flexion (15)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 11;

%% 11: Middle2 flexion (16)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 12;

%% 12: Middle3 flexion (17)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 13;

%% 13: Ring1 abduction (18)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'Z';
theta{i}.segment_id = 8;

%% 14: Ring1 flexion (19)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 8;

%% 15: Ring2 flexion (20)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 9;

%% 16: Ring3 flexion (21)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 10;

%% 17: Pinky1 abduction (22)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'Z';
theta{i}.segment_id = 5;

%% 18: Pinky1 flexion (23)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 5;

%% 19: Pinky2 flexion (24)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 6;

%% 20: Pinky3 flexion (25)
i = i + 1;
theta{i}.value = t(i);
theta{i}.axis = 'X';
theta{i}.segment_id = 7;


