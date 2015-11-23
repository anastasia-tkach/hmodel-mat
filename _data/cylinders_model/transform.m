function [V] = transform(V, T)

D = size(V, 1);

V = [V; ones(1, size(V, 2))];    
V = T * V;
V = bsxfun(@rdivide, V, V(D + 1, :));

V = V(1:D, :);