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
num_poses = 3; 
start_pose = 1;
num_iters = 10;

%% Compute weights
damping = 10; w1 = 1; w2 = 1000; w3 = 1;  w4 = 0.1; w5 = 1;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; 
settings.w4 = w4; settings.w5 = w5;

%% Optimize
success_iter =  0;

%% Tracking
% damping = 1;
% w2 = 1e10;
% settings.w2 = w2; 
% settings.damping = damping;
% settings.mode = 'tracking';
% data_path = '_data/implicit_skinning/tracking/';
% num_poses = 1;
% start_pose = 4;





