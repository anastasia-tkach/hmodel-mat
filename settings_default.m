clc;
clear;
close all;

set_path;
data_path = '_data/implicit_skinning/old/';
D = 3;

%% Settings
settings.mode = 'fitting';

settings.sparse_data = false;
settings.closing_radius = 25;
settings.fov = 15;
downscaling_factor = 16;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D;
settings.RAND_MAX = 32767;

settings.energy1 = true; 
settings.energy2 = true; 
settings.energy3x = false; 
settings.energy3y = false; 
settings.energy3z = false;
settings.energy4 = true;
settings.energy5 = true;

settings.linear_search = false;

%% Set up optimization
num_poses = 1; 
start_pose = 1;
num_iters = 15;

%% Compute weights
damping = 10; w1 = 1; w2 = 1000; w3 = 1;  w4 = 1; w5 = 1;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; 
settings.w4 = w4; settings.w5 = w5;

%% Optimize
success_iter =  0;

%% Tracking
damping = 0.001;
w2 = 50;
settings.w2 = w2; 
w3 = 1e4;
settings.w3 = w3; 
settings.damping = damping;
settings.mode = 'tracking';

data_path = '_data/fingers/';
num_poses = 1;
start_pose = 5;

settings.energy1 = false; 
settings.energy2 = false; 
settings.energy3 = true; 
settings.energy3x = false; 
settings.energy3y = false; 
settings.energy3z = false;
settings.energy4 = true;
settings.energy5 = false;

settings.skeleton = false;


data_path = '_data/implicit_skinning/tracking/';

