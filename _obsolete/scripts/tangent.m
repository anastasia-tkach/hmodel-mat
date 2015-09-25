%close all; clc;

clear;
while(true)
    c1 = 0.5 * rand(2 ,1);
    c2 = 0.5 * rand(2 ,1);
    x1 = rand(1 ,1);
    x2 = rand(1 ,1);
    r1 = max(x1, x2);
    r2 = min(x1, x2);
    p = rand(2, 1);
    if norm(c1 - c2) > r1
        break;
    end
end

indices = [];

u = c2 - c1;
v = p - c1;

alpha = u' * v / (u' * u);
t = c1 + alpha * u;

omega = sqrt(u' * u - (r1 - r2)^2);
delta =  norm(p - t) * (r1 - r2) / omega;

if alpha <= 0
    t = c1;
    q =  c1 + r1 * (p - c1) / norm(p - c1);
    indices = [1];
end
if (alpha > 0 && alpha < 1)
    if (norm(c1 - t) < delta)
        t = c1;
        q = c1 + r1 * (p - c1) / norm(p - c1);
        indices = [1];
    end
end
if (alpha >= 1)
    if (norm(t - c2) > delta)
        t = c2;
        q = c2 + r2 * (p - c2) / norm(p - c2);
        indices = [2];
    end    
    if norm(c1 - c2) < delta
        t = c1;
        q =  c1 + r1 * (p - c1) / norm(p - c1);     
        indices = [2];
    end
end   

if isempty(indices)
    s = t - delta * (c2 - c1) / norm(c2 - c1);
    gamma = (r1 - r2) * norm(c2 - t + delta * u / norm(u))/ sqrt(u' * u);
    q = s + (p - s) / norm(p - s) * (gamma + r2);
    indices = [1, 2];
end

disp(indices);


%% Display
figure; hold on;
draw_circle(c1, r1, 'b');
draw_circle(c2, r2, 'b');
draw_circle(c1, r1 - r2, 'c');

draw_tangents([r1, r2], [c1'; c2'], 'b');
line([c1(1), c2(1)], [c1(2), c2(2)], 'lineWidth', 2, 'color', 'm');
line([p(1) t(1)], [p(2), t(2)], 'lineWidth', 2);
if exist('s', 'var')
    line([p(1) s(1)], [p(2), s(2)], 'lineWidth', 2);
    scatter(s(1), s(2), 30, 'y', 'filled');
end
scatter(p(1), p(2), 30, 'm', 'filled');
scatter(c1(1), c1(2), 30, 'b', 'filled');
scatter(c2(1), c2(2), 30, 'b', 'filled');
scatter(t(1), t(2), 30, 'y', 'filled');
scatter(q(1), q(2), 60, 'g', 'filled');

%% Tangents
beta = atan((r1 - r2) / omega);
theta = atan2(u(2), u(1));
if (theta < 0)
    theta = 2 * pi + theta;
end
phi = pi/2 - beta;
q11 = [c1(1) + r1 * cos(theta + phi); c1(2) + r1 * sin(theta + phi)];
q12 = [c1(1) + r1 * cos(theta - phi); c1(2) + r1 * sin(theta - phi)];

q21 = [c2(1) + r2 * cos(theta + phi); c2(2) + r2 * sin(theta + phi)];
q22 = [c2(1) + r2 * cos(theta - phi); c2(2) + r2 * sin(theta - phi)];

q31 = [c1(1) + (r1 - r2) * cos(theta + phi); c1(2) + (r1 - r2) * sin(theta + phi)];
q32 = [c1(1) + (r1 - r2) * cos(theta - phi); c1(2) + (r1 - r2) * sin(theta - phi)];

scatter(q11(1), q11(2), 30, 'c', 'filled');
scatter(q21(1), q21(2), 30, 'c', 'filled');
scatter(q31(1), q31(2), 30, 'c', 'filled');
scatter(q12(1), q12(2), 30, 'c', 'filled');
scatter(q22(1), q22(2), 30, 'c', 'filled');
scatter(q32(1), q32(2), 30, 'c', 'filled');
line([c1(1) q11(1)], [c1(2), q11(2)], 'lineWidth', 2);
line([c2(1) q21(1)], [c2(2), q21(2)], 'lineWidth', 2);
line([q11(1) q21(1)], [q11(2), q21(2)], 'lineWidth', 2);

line([c1(1) q12(1)], [c1(2), q12(2)], 'lineWidth', 2);
line([c2(1) q22(1)], [c2(2), q22(2)], 'lineWidth', 2);
line([q12(1) q22(1)], [q12(2), q22(2)], 'lineWidth', 2);


axis equal;





