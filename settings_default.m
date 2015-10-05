clc;
clear;
close all;

set_path;
data_path = '_data/implicit_skinning/new/';
D = 3;

%% Settings
settings.mode = 'fitting';
settings.r_min = 0.5;
settings.sparse_data = false;
settings.closing_radius = 25;
settings.fov = 15;
downscaling_factor = 8;
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

settings.linear_search = true;

%% Set up optimization
num_poses = 3; 
num_iters = 20;

%% Compute weights
damping = 10; w1 = 1; w2 = 1000; w3 = 1;  w4 = 0.1; w5 = 1;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; 
settings.w4 = w4; settings.w5 = w5;


%% Optimize
success_iter =  0;















%% Pose 1
poses{1}.centers{1} = [-2.801; -1.052; 0.419]; radii{1} = 0.5;
poses{1}.centers{2} = [-3.64; -1.883; 0.11]; radii{2}  = 0.7;
poses{1}.centers{3} = [-4.371; -2.38; 1.515]; radii{3}  = 0.8;
poses{1}.centers{4} = [-4.006; -1.225; 3.879]; radii{4}  = 1.2;

poses{1}.centers{5} = [-1.585; -1.57; -0.388]; radii{5} = 0.65;
poses{1}.centers{6} = [-1.949; -3.072; -0.147]; radii{6} = 0.8;
poses{1}.centers{7} = [-2.343; -3.928; 1.939]; radii{7} = 1;
poses{1}.centers{8} = [-2.133; -1.997; 4.708]; radii{8} = 1.3;

poses{1}.centers{9} = [0.002; -1.661; -0.018]; radii{9} = 0.65;
poses{1}.centers{10} = [0.127; -3.011; -0.443]; radii{10} = 0.8;
poses{1}.centers{11} = [-0.283; -4.848; 1.834]; radii{11} = 0.8;
poses{1}.centers{12} = [-0.319; -2.632; 4.878]; radii{12} = 1.3;

poses{1}.centers{13} = [1.921; -3.504; 0.327]; radii{13} = 0.7;
poses{1}.centers{14} = [2.106; -4.718; 0.623]; radii{14} = 0.8;
poses{1}.centers{15} = [2.021; -5.279; 2.627]; radii{15} = 1;
poses{1}.centers{16} = [1.951; -2.705; 4.829]; radii{16} = 1.3;

poses{1}.centers{17} = [4.935; -0.96; -3.319]; radii{17} = 0.7;
poses{1}.centers{18} = [5.912; 0.381; -2.516]; radii{18} = 0.9;
poses{1}.centers{19} = [3.796; 2.246; 0.568]; radii{19} = 1.5;
poses{1}.centers{20} = [1.452; 3.153; 1.673]; radii{20} = 2;

poses{1}.centers{21} = [4.056; 0.752; 0.783]; radii{21} = 0.6;

poses{1}.centers{28} = [-3.341; -1.962; 3.513]; radii{28} = 0.4;
poses{1}.centers{29} = [-1.179; -2.843; 4.261]; radii{29} = 0.4;
poses{1}.centers{30} = [0.717; -3.367; 4.316]; radii{30} = 0.4;

%% Pose 2

poses{2}.centers{1} = [-4.953; -5.001; 7.997]; radii{1} = 0.5;
poses{2}.centers{2} = [-5.026; -3.425; 8.224]; radii{2}  = 0.6;
poses{2}.centers{3} = [-4.954; -1.671; 8.272]; radii{3}  = 0.8;
poses{2}.centers{4} = [-3.864; 1.377; 6.914]; radii{4}  = 1.2;

poses{2}.centers{5} = [-3.939; -6.3; 11.124]; radii{5} = 0.65;
poses{2}.centers{6} = [-3.633; -4.582; 10.905]; radii{6} = 0.7;
poses{2}.centers{7} = [-3.148; -2.113; 10.295]; radii{7} = 1;
poses{2}.centers{8} = [-2.094; 1.087; 8.18]; radii{8} = 1.3;

poses{2}.centers{9} = [-1.758; -7.132; 12.038]; radii{9} = 0.65;
poses{2}.centers{10} = [-1.408; -5.577; 11.737]; radii{10} = 0.75;
poses{2}.centers{11} = [-0.983; -2.789; 11.201]; radii{11} = 1;
poses{2}.centers{12} = [-0.197; 0.85; 8.605]; radii{12} = 1.3;

poses{2}.centers{13} = [2.087; -4.44; 9.803]; radii{13} = 0.65;
poses{2}.centers{14} = [2.118; -4.262; 10.962]; radii{14} = 0.8;
poses{2}.centers{15} = [2.101; -2.448; 11.397]; radii{15} = 1;
poses{2}.centers{16} = [2.045; 0.703; 8.778]; radii{16} = 1.3;

poses{2}.centers{17} = [4.462; -2.845; 7.628]; radii{17} = 0.7;
poses{2}.centers{18} = [4.729; -1.002; 6.546]; radii{18} = 0.9;
poses{2}.centers{19} = [3.759; 1.639; 4.634]; radii{19} = 1.5;
poses{2}.centers{20} = [1.445; 3.632; 3.112]; radii{20} = 2;

poses{2}.centers{21} = [3.22; 1.41; 5.638]; radii{21} = 0.6;

poses{2}.centers{28} = [-3.177; 0.182; 7.811]; radii{28} = 0.4;
poses{2}.centers{29} = [-1.389; -0.477; 8.787]; radii{29} = 0.4;
poses{2}.centers{30} = [0.72; -0.797; 9.391]; radii{30} = 0.4;

%% Pose 3

poses{3}.centers{1} = [-3.609; 0.091; 0.933]; radii{1} = 0.5;
poses{3}.centers{2} = [-3.2; -0.593; 0.033]; radii{2}  = 0.6;
poses{3}.centers{3} = [-4.063; -1.924; 0.173]; radii{3}  = 0.8;
poses{3}.centers{4} = [-4.027; -1.561; 2.495]; radii{4}  = 1.1;

poses{3}.centers{5} = [-2.263; -0.618; 0.716]; radii{5} = 0.65;
poses{3}.centers{6} = [-1.842; -0.911; -0.661]; radii{6} = 0.7;
poses{3}.centers{7} = [-2.19; -2.862; 0.05]; radii{7} = 1;
poses{3}.centers{8} = [-2.047; -2.525; 2.945]; radii{8} = 1.3;

poses{3}.centers{9} = [-0.038; -0.517; 0.504]; radii{9} = 0.65;
poses{3}.centers{10} = [0.077; -0.627; -1.051]; radii{10} = 0.75;
poses{3}.centers{11} = [-0.035; -3.118; -0.357]; radii{11} = 1;
poses{3}.centers{12} = [-0.384; -3.1; 3.114]; radii{12} = 1.3;

poses{3}.centers{13} = [2.007; -0.68; 0.018]; radii{13} = 0.65;
poses{3}.centers{14} = [2.079; -1.447; -0.933]; radii{14} = 0.8;
poses{3}.centers{15} = [2.054; -2.925; -0.04]; radii{15} = 1;
poses{3}.centers{16} = [2.055; -2.986; 3.014]; radii{16} = 1.3;

poses{3}.centers{17} = [3.128; -4.54; -0.179]; radii{17} = 0.7;
poses{3}.centers{18} = [3.997; -2.545; 0.505]; radii{18} = 0.9;
poses{3}.centers{19} = [2.923; 2.227; 1.176]; radii{19} = 1.5;
poses{3}.centers{20} = [1.179; 3.438; 1.511]; radii{20} = 2;

poses{3}.centers{21} = [3.069; -0.308; 1.824]; radii{21} = 0.6;

poses{3}.centers{28} = [-3.045; -2.072; 1.915]; radii{28} = 0.4;
poses{3}.centers{29} = [-1.263; -2.821; 2.242]; radii{29} = 0.4;
poses{3}.centers{30} = [0.844; -3.333; 2.276]; radii{30} = 0.4;


blocks{44} = [1, 2, 3, 4];
blocks{45} = [3, 4, 5, 6];
blocks{46} = [8, 9, 10, 11];
blocks{47} = [10, 11, 12 ,13];
blocks{48} = [15, 16, 17, 18];
blocks{49} = [17, 18, 19, 20];
blocks{50} = [22, 23, 24, 25];
blocks{51} = [24, 25, 26, 27];
blocks{52} = [29, 30, 31, 32];
blocks{53} = [31, 32, 33, 34];



