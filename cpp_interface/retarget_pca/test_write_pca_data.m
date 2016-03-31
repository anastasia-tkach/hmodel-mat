
close all; 
clear; clc;
n = 20; m = 2; p = 6;

%load Data; Data = Data(:, p + 1:end);
load MData_12000_2;
Data = MData_12000_2;

mu = mean(Data)';
Data = bsxfun(@minus, Data, mu');
Y = Data;
y = [0.2245, 0.6083, -0.1260, -1.0965, -0.1580, -1.0081, -0.6572, -1.0159, ...
    -0.2056, 0.0670, -1.1924, -0.9529, -0.2882, -1.2361, -0.5992, -0.1336, ...
    0.0659, -0.8790, -1.6130, -1.9549]';

%% Compute split PCA
num_thetas_thumb = 4;
num_thetas_fingers = 16;
m1 = 2; m4 = 2;
n1 = 4; n4 = 16;

Y1 = Y(:, 1:num_thetas_thumb);
Y4 = Y(:, num_thetas_thumb+ 1:end);

[P1, s1] =  compute_pca_transformation(Y1, m1);
[P4, s4] =  compute_pca_transformation(Y4, m4);

y1 = y(1:n1);
y4 = y(n1 + 1:end);
x1 = P1' * y1;
x4 = P4' * y4;
Sigma1 = s1; Sigma4 = s4;

%% Display PCA space

% P = P4;
% y = zeros(1, n);
% Y = Y4;
% s = s4;
% Yk = Y *  P; 
% x1 = linspace(min(Yk(:, 1))*1.1, max(Yk(:, 1))*1.1, 1000);
% x2 = linspace(min(Yk(:, 2))*1.1, max(Yk(:, 2))*1.1, 1000);
% [X1, X2] = meshgrid(x1, x2);
% C = mvnpdf([X1(:) X2(:)], [0, 0], 3 * s);
% C = reshape(C, size(X1));
% axis equal;
% imagesc(x1, x2, C); hold on;
% colormap jet; axis off;
%explore_split_pca_space(P4, zeros(1, n), Y4, s4, 4);


%% Write for cpp

X1 = Y1 *  P1; 
Limits1 = 1.1 * [min(X1(:, 1))*1.1, max(X1(:, 1))*1.1;
                min(X1(:, 2))*1.1, max(X1(:, 2))*1.1];
X4 = Y4 *  P4; 
Limits4 = 1.1 * [min(X4(:, 1))*1.1, max(X4(:, 1))*1.1;
                min(X4(:, 2))*1.1, max(X4(:, 2))*1.1];
            
            
% write_binary_matrix(Limits1, 'C:\Users\tkach\Desktop\Limits1');
% write_binary_matrix(P1, 'C:\Users\tkach\Desktop\P1');
% write_binary_matrix(s1, 'C:\Users\tkach\Desktop\Sigma1');

write_binary_matrix(Limits4, 'C:\Users\tkach\Desktop\Limits');
write_binary_matrix(P4, 'C:\Users\tkach\Desktop\P');
write_binary_matrix(s4, 'C:\Users\tkach\Desktop\Sigma');
write_binary_matrix(mu, 'C:\Users\tkach\Desktop\mu');


