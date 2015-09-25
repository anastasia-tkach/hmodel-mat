clear all; close all;
figure; hold on; axis equal;
xlim([0 1]);
ylim([0 1]);
P = [];
i = 0;
while(true)
    i = i + 1;
    [x, y, key] = ginput(1);
    P = [P; [x, y]];
    if (key == 3), break; end
    if (i > 1)
        line(P(i-1:i, 1), P(i-1:i, 2), 'lineWidth', 2);
    end
end
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2);


%% Initialize r and c
[cx, cy] = ginput(1);
c = [cx; cy];
scatter(c(1), c(2), 10, 'r', 'filled');
[tx, ty] = ginput(1);
r = norm(c - [tx; ty]);
draw_circle(c, r, 'g');

save P P; save c c; save r r;

%close all; clc; clear;
% load P;
% load c;
% load r;

%% Display results
figure; hold on; axis equal;
xlim([0 1]);
ylim([0 1]);
line(P(:, 1), P(:, 2), 'lineWidth', 2);
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2);
scatter(c(1), c(2), 10, 'r', 'filled');
draw_circle(c, r, 'g');

%% Compute gradient
N = size(P, 1);
f = zeros(N, 1);
J = zeros(N, 3);
Jnum = zeros(N, 3);
alpha = 0.1;

for t = 1:10
    
    x = [c(1); c(2); r];
    
    
    for i = 1:N
        p = P(i, :)';
        f(i) = p' * p - 2 * p' * c + c' * c - r * r; % (p - c)' * (p - c) - r * r
        J(i, 1) = -2 * p(1) + 2 * c(1);
        J(i, 2) = -2 * p(2) + 2 * c(2);
        J(i, 3) = -2 * r;
        
        g = @(x) p' * p - 2 * p' * [x(1); x(2)] + [x(1); x(2)]' * [x(1); x(2)] - x(3) * x(3);
        Jnum(i, :) =  gradient(g, x);
    end
    
    disp(norm(f))
    delta = - (J' * J) \ (J' * f);
    
    c = c + delta(1:2);
    r = r + delta(3);
    
    
    %% Display results
    figure; hold on; axis equal;
    xlim([0 1]);
    ylim([0 1]);
    line(P(:, 1), P(:, 2), 'lineWidth', 2);
    line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2);
    scatter(c(1), c(2), 10, 'r', 'filled');
    draw_circle(c, r, 'g');
    
    
end


