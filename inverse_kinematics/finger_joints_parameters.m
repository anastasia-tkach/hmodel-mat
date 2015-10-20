function [theta] = finger_joints_parameters(t)

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

%% 7: Pinky2 flexion 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 2;

%% 8: Pinky3 flexion 
i = i + 1;
theta{i}.value = t(i);
theta{i}.type = 'R';
theta{i}.axis = [1; 0; 0];
theta{i}.segment_id = 3;


