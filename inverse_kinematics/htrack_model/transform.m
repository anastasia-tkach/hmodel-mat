function [V] = transform_segment(V, T)

V = [V; ones(1, size(V, 2))];    
V = T * V;
V = bsxfun(@rdivide, V, V(4, :));

V = V(1:3, :);