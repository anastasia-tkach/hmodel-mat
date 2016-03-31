function [P, s] =  compute_pca_transformation(X, m)

Sigma = (X' * X) / size(X, 1); 
[U, S, ~] = svd(Sigma);
s = diag(S);

s = diag(s(1:m));
P = U(:, 1:m);

%Xp = P' * X'; 