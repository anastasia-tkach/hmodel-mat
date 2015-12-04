clc;
clear;
%close all;

set_path;
D = 3;

%% Settings
settings.mode = 'fitting';

settings.sparse_data = false;
settings.closing_radius = 10;
settings.fov = 15;
downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 636/downscaling_factor;
%settings.W = 640/downscaling_factor;
settings.D = D;
settings.RAND_MAX = 32767;
settings.side = 'front';
settings.view_axis = 'Z';

settings.energy1 = true; 
settings.energy2 = true; 
settings.energy4 = true;
settings.energy5 = true;

%% Set up optimization
num_poses = 2; 
start_pose = 1;
num_iters = 10;

%% Compute weights
damping = 10; w1 = 1; w2 = 1000; w3 = 1;  w4 = 1; w5 = 10;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; 
settings.w4 = w4; settings.w5 = w5;




