% clc; clear; close all;
% D = 3;
% alpha_true = rand;

% 
% a = randn(D, 1);
% b = Rx(alpha_true) * a;
% 
% alpha = alpha_true + 0.05;
% num_iter = 100;
% I = 0.01 * eye(1, 1);
% alpha_history = zeros(num_iter, 1);
% f_history = zeros(num_iter, 1);
% alpha_history(1) = alpha;
% delta_history = zeros(num_iter, 1);
% for iter = 2:num_iter
%     J = Rx(alpha) * a;
%     f = b - Rx(alpha) * a;
%     delta_alpha = -(J' * J + I) \ (J' * f);
%     alpha = alpha + delta_alpha;
%     if (alpha > pi), alpha  = 2 * pi - alpha; end
%     alpha_history(iter) = alpha;
%     f_history(iter - 1) = f' * f;
%     delta_history(iter) = delta_alpha;
%  end
% f_history(num_iter) = (b - Rx(alpha) * a)' * (b - Rx(alpha) * a);
% 
% figure; 
% plot(1:num_iter, alpha_true * ones(num_iter, 1), 'lineWidth', 2); hold on;
% plot(1:num_iter, alpha_history, 'lineWidth', 2); 
% plot(1:num_iter, f_history, 'lineWidth', 2); 
% plot(1:num_iter, delta_history, 'lineWidth', 2); 
% legend({'alpha true', 'alpha', 'f', 'delta'});
clc;
Rx = @(alpha) [1, 0, 0;
    0, cos(alpha), -sin(alpha);
    0, sin(alpha), cos(alpha)];

Rz = @(alpha)[cos(alpha), -sin(alpha), 0;
    sin(alpha), cos(alpha), 0;
    0, 0, 1];

alpha_true = rand(2, 1);
a = rand(D, 1);
b = Rz(alpha_true(2)) * Rx(alpha_true(1)) * a; 
fun = @(alpha) Rz(alpha(2)) * Rx(alpha(1)) * a - b;
alpha0 = rand(2, 1);
[alpha_ls, resnorm] = lsqnonlin(fun, alpha0, [0; 0], [pi; pi]);

disp([alpha_true, alpha_ls])



