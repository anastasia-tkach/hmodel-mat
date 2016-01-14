function [theta] =  joints_parameters(t)

i = 0;

%% 1: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = 'X';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 2: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = 'Y';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 3: Global translation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'T';
theta{i}.axis = 'Z';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 4: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 5: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Y';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 6: Global rotation 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 1;
theta{i}.min = -Inf;
theta{i}.max = Inf;

%% 7: Thumb1 abduction (6)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 2;
theta{i}.min = -0.3;
theta{i}.max = 0.3;

%% 8: Thumb1 flexion (7)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 2;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 9: Thumb2 flexion (8)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 3;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 10: Thumb3 flexion (9)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 4;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 11: Index1 abduction (10)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 14;
theta{i}.min = -0.5;
theta{i}.max = 0.4;

%% 12: Index1 flexion (11)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 14;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 13: Index2 flexion (12)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 15;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 14: Index3 flexion (13)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 16;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 15: Middle1 abduction (14)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 11;
theta{i}.min = -0.3;
theta{i}.max = 0.3;

%% 16: Middle1 flexion (15)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 11;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 17: Middle2 flexion (16)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 12;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 18: Middle3 flexion (17)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 13;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 19: Ring1 abduction (18)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 8;
theta{i}.min = -0.3;
theta{i}.max = 0.3;

%% 20: Ring1 flexion (19)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 8;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 21: Ring2 flexion (20)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 9;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 22: Ring3 flexion (21)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 10;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 23: Pinky1 abduction (22)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'Z';
theta{i}.segment_id = 5;
theta{i}.min = -0.3;
theta{i}.max = 0.3;

%% 24: Pinky1 flexion (23)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 5;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 25: Pinky2 flexion (24)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 6;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

%% 26: Pinky3 flexion (25)
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = 'X';
theta{i}.segment_id = 7;
theta{i}.min = -1.5;
theta{i}.max = 0.1;

