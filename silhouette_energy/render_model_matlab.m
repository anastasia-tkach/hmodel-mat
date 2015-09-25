function [U, V, D] = render_model_matlab(centers, blocks, radii, tangent_points, W, H, P, p)

% D = -1.5 * ones(H, W);
% while true
%     n = randi([1, W], 1, 1);
%     m = randi([1, H], 1, 1);
%     d = P * [n; m; 1];
%     d = d / norm(d);
%
%     i = ray_model_intersection(centers, blocks, radii, tangent_points, p, d);
%     if (norm(i) < Inf)
%         D(m, n) = i(3);
%         [n, m]
%         i'
%         mypoint(i, 'y');
%         break;
%     end
% end

RAND_MAX = 32767;
skip = 1;
U = -RAND_MAX * ones(H, W);
V = -RAND_MAX * ones(H, W);
D = -RAND_MAX * ones(H, W);
%% Display rays

for n = 1:skip:W
    for m = 1:skip:H
        d = P * [n; m; 1];
        d = d / norm(d);
        if (n == 36 && m == 43)
            disp('');
            save d d;
            save p p;
        end
        i = ray_model_intersection(centers, blocks, radii, tangent_points, p, d);
        if (norm(i) < Inf)
            U(m, n) = i(1);
            V(m, n) = i(2);
            D(m, n) = i(3);
        end
    end
end








