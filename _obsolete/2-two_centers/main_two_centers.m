% clear all; close all;
% figure; hold on; axis equal;
% 
% xlim([0 1]);
% ylim([0 1]);
% P = [];
% i = 0;
% while(true)
%     i = i + 1;
%     [x, y, key] = ginput(1);
%     P = [P; [x, y]];
%     if (key == 3), break; end
%     if (i > 1)
%         line(P(i-1:i, 1), P(i-1:i, 2), 'lineWidth', 2);
%     end
% end
% line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2);
% 
% C = [];
% R = [];
% for i = 1:2
%     [cx, cy] = ginput(1);
%     C = [C; [cx cy]];
%     scatter(cx, cy, 20, 'r', 'filled');
%     [tx, ty] = ginput(1);
%     R = [R; norm(C(i, :)' - [tx; ty])];
%     draw_circle(C(i, :), R(i),  [0, 0.9, 0.6]);
% end
% draw_tangents(R, C);
% 
% save P P;
% save R R;
% save C C;


%% Solve

close all; clc; clear;
load P;
load R;
load C;

close all;
colors = {[1, 0.3, 0.5], [1, 0.8, 0], [1, 0.5, 0.2]};


%% Compute gradient
N = size(P, 1);
f = zeros(N, 1);
J = zeros(N, 6);
alpha = 0.1;

for t = 1:10
    
    display_two_centers(P, C, R)
    
    %% Compute correspondences
    I = zeros(size(P, 1), 1);
    for i = 1:size(P, 1)
        u = (C(2, :) - C(1, :))';
        v = (P(i, :) - C(1, :))';
        projection = u' * v / (u' * u);
        if projection <= 0,
            I(i) = 1;
        end
        if projection > 0 && projection <= 1
            I(i) = 2;
        end
        if projection > 1
            I(i) = 3;
        end
    end
    
    for i = 1:size(P, 1)
        scatter(P(i, 1), P(i, 2), 30, colors{I(i)}, 'filled');
    end
    
    %% Compute updates
    
    for i = 1:N
        p = P(i, :)';
        %% Case 1
        if I(i) == 1
            [fi, Ji] = case1(p, C(1, :)', R(1, :)');
            f(i) = fi;
            J(i, :) = [Ji(1:2), 0, 0, Ji(3), 0];
            c = C(1, :)';
            r = R(1, :)';
        end
        
        %% Case 2
        if I(i) == 2
            [fi, Ji, c, r] = case2(p, C, R);
            f(i) = fi;
            J(i, :) = Ji;
        end
        
        %% Case 3
        if I(i) == 3
            [fi, Ji] = case1(p, C(2, :)',  R(2, :)');
            f(i) = fi;
            J(i, :) = [0, 0, Ji(1:2), 0, Ji(3)];
            c = C(2, :)';
            r = R(2, :)';
        end
        
        q = p - (norm(p - c) - r) * (p - c) / norm(p - c);
        scatter(q(1), q(2), 30, colors{I(i)}, 'filled');
        line([q(1), p(1)], [q(2), p(2)], 'lineWidth', 2, 'color', colors{I(i)});
        
    end
    
    disp(norm(f))
    delta = - (J' * J + alpha * eye(6, 6)) \ (J' * f);
    
    C(1, :) = C(1, :) + delta(1:2)';
    C(2, :) = C(2, :) + delta(3:4)';
    R(1) = R(1) + delta(5);
    R(2) = R(2) + delta(6); 
    
end




