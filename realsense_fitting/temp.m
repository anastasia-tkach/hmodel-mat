% n = 7;
% x = randn(n, 1);
% a = randn(n, 1);
% I = eye(n, n);
% 
% for i = 1:1
%     f = x - a;
%     J = eye(n ,n);
%     rhs = J' * f;
%     lhs = J' * J;
%     delta = - lhs \ rhs;
%     x = x + delta;
% end
% 
% disp([x, a]);
% 
% return

input_path = 'realsense_fitting/andrii/';
output_path = 'realsense_fitting/andrii/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

load([output_path, 'poses.mat']);
load([output_path, 'radii.mat']);
load([output_path, 'blocks.mat']);
load([input_path, 'alpha.mat']);


synchronize_transformations(poses, blocks, alpha, names_map);
