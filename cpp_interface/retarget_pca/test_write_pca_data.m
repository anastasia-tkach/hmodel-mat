
close all;
clear; clc;

num_thetas = 29;
num_thetas_ignore = 9;

mode = 'fingers';

if strcmp(mode, 'fingers')
    %load MData_Fingers1;
end

path = 'C:\Developer\hmodel-cuda-build\data\sensor\hmodel_solutions.txt';
fileID = fopen(path, 'r');
Data = fscanf(fileID, '%f');
N = length(Data)/num_thetas;
Data = reshape(Data, num_thetas, N)';
Data = Data(:, num_thetas_ignore + 1:end);

mu = mean(Data)';
Data = bsxfun(@minus, Data, mu');
Y = Data;


%% Compute split PCA
num_thetas_thumb = 4;
num_thetas_fingers = 16;
m1 = 2; m4 = 2;
n1 = 4; n4 = 16;

if strcmp(mode, 'thumb')
    Y1 = Y(:, 1:num_thetas_thumb);
    [P1, s1] =  compute_pca_transformation(Y1, m1);
    Sigma1 = s1;
    
    P = P1;
    Y = Y1;
    s = s1;
end
if strcmp(mode, 'fingers')
    Y4 = Y(:, num_thetas_thumb + 1:end);
    [P4, s4] =  compute_pca_transformation(Y4, m4);
    Sigma4 = s4;
    
    P = P4;
    Y = Y4;
    s = s4;
end

%% Display PCA space

Yk = Y *  P;
x1 = linspace(min(Yk(:, 1))*1.1, max(Yk(:, 1))*1.1, 1000);
x2 = linspace(min(Yk(:, 2))*1.1, max(Yk(:, 2))*1.1, 1000);
[X1, X2] = meshgrid(x1, x2);
C = mvnpdf([X1(:) X2(:)], [0, 0], 3 * s);
C = reshape(C, size(X1));
axis equal;
imagesc(x1, x2, C); hold on;
colormap jet; axis off;
plot(Yk(1:end, 1), Yk(1:end, 2), 'ko', 'markerSize', 1, 'markerFaceColor', [1, 1, 1], 'markerEdgeColor', [1, 1, 1]);


%% Write for cpp

load MData_Thumb;
mu_thumb = mean(MData_Thumb)';
mu(1:4) = mu_thumb(1:4);
write_binary_vector(mu, 'C:\Users\tkach\Desktop\mu');

if strcmp(mode, 'thumb')
    X1 = Y1 *  P1;
    Limits1 = 1.1 * [min(X1(:, 1))*1.1, max(X1(:, 1))*1.1;
        min(X1(:, 2))*1.1, max(X1(:, 2))*1.1];
    
    write_binary_matrix(Limits1, 'C:\Users\tkach\Desktop\Limits1');
    write_binary_matrix(P1, 'C:\Users\tkach\Desktop\P1');
    write_binary_matrix(s1, 'C:\Users\tkach\Desktop\Sigma1');
end

if strcmp(mode, 'fingers')
    X4 = Y4 *  P4;
    Limits4 = 1.1 * [min(X4(:, 1))*1.1, max(X4(:, 1))*1.1;
        min(X4(:, 2))*1.1, max(X4(:, 2))*1.1];
    
    write_binary_matrix(Limits4, 'C:\Users\tkach\Desktop\Limits4');
    write_binary_matrix(P4, 'C:\Users\tkach\Desktop\P4');
    write_binary_matrix(s4, 'C:\Users\tkach\Desktop\Sigma4');
end




