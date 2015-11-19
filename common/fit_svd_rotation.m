function [R] = fit_svd_rotation(E, F)

% E - initial, F - current

D = 3;

S = F' * E;
[U, ~, V] = svd(S);
R = V * U';
if det(R) < 0, 
    U(:, D) = -  U(:, D); 
    R = V * U'; 
end