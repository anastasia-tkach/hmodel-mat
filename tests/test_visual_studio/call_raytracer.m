clear; clc; close all;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\robert_wang\'];
% data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);


p = 1;
num_poses = 1;
% load([data_path, 'points']);
% load([data_path, 'centers']);
load([data_path, num2str(p), '_points']);
load([data_path, num2str(p), '_centers']);
poses{p}.centers = centers;
poses{p}.num_centers = length(centers);

%% Call

H = 480; W = 640;
RAND_MAX = 32767;

%render_model_transition(centers, blocks, radii);

rendered_model = render_model(centers, blocks, radii, W, H, 'X');
rendered_model(rendered_model == -RAND_MAX) = -100;
figure; imshow(rendered_model, []); 

rendered_model = render_model(centers, blocks, radii, W, H, 'Y');
rendered_model(rendered_model == -RAND_MAX) = -100;
figure; imshow(rendered_model, []); 

rendered_model = render_model(centers, blocks, radii, W, H, 'Z');
rendered_model(rendered_model == -RAND_MAX) = -100;
figure; imshow(rendered_model, []); 


