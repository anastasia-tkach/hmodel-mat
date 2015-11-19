function [R] = find_svd_rotation(initial_frame, current_frame)

D = 3;

% c1 = initial_centers{1}; c2 = initial_centers{2}; c3 = initial_centers{3};
% d1 = current_centers{1}; d2 = current_centers{2}; d3 = current_centers{3};
% 
% a = (c2 - c1) / norm(c2 - c1);
% b = (c3 - c1) / norm(c3 - c1);
% 
% x = (d2 - d1) / norm(d2 - d1);
% y = (d3 - d1) / norm(d3 - d1);
% 
% E = [a'; b'];
% F = [x'; y'];

E = initial_frame';
F = current_frame';

S = F' * E;
[U, ~, V] = svd(S);
R = V * U';
if det(R) < 0, 
    U(:, D) = -  U(:, D); 
    R = V * U'; 
end