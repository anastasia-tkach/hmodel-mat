% clear
% 
close all;
v1 = rand(3, 1);
v2 = rand(3, 1);
v3 = rand(3, 1);
while(true)
    p1 = rand(3, 1);
    index1 = 1;
    index2 = 2;
    index3 = 3;    
    [t1, index] = closest_point_in_triangle(v1, v2, v3, p1, index1, index2, index3);   
    if (length(index) == 3)
        break;
    end
end
p1 = t1;

while(true)
    p2 = rand(3, 1);
    index1 = 1;
    index2 = 2;
    index3 = 3;    
    [t2, index] = closest_point_in_triangle(v1, v2, v3, p2, index1, index2, index3);   
    if (length(index) == 3)
        break;
    end
end
p2 = t2;

figure; hold on; axis equal;
line([v1(1) v2(1)], [v1(2) v2(2)], [v1(3) v2(3)], 'lineWidth', 1);
line([v1(1) v3(1)], [v1(2) v3(2)], [v1(3) v3(3)], 'lineWidth', 1);
line([v2(1) v3(1)], [v2(2) v3(2)], [v2(3) v3(3)], 'lineWidth', 1);
scatter3(p1(1), p1(2), p1(3), 30, 'filled', 'm');
scatter3(p2(1), p2(2), p2(3), 30, 'filled', 'y');
line([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], 'lineWidth', 2, 'color', 'm');

%% Solve for intersecton

p = p2 - p1;

a = (v2 - v1) / norm(v2 - v1);
b = (v3 - v1) / norm(v3 - v1);
c = (v3 - v2) / norm(v3 - v2);

projection_a = p' * a;
projection_b = p' * b;
projection_c = p' * c;

qa = projection_a * a;
qb = projection_b * b;
qc = projection_c * c;

alpha = (p1 - v1)' * a; ta = v1 + a * alpha;
alpha = (p1 - v1)' * b; tb= v1 + b * alpha;
sa = ta + qa;
sb = tb + qb;


scatter3(ta(1), ta(2), ta(3), 30, 'filled', 'y');
scatter3(tb(1), tb(2), tb(3), 30, 'filled', 'y');
line([ta(1) sa(1)], [ta(2) sa(2)], [ta(3) sa(3)], 'lineWidth', 4, 'color', 'c');
line([tb(1) sb(1)], [tb(2) sb(2)], [tb(3) sb(3)], 'lineWidth', 4, 'color', 'c');

line([p1(1) ta(1)], [p1(2) ta(2)], [p1(3) ta(3)], 'lineWidth', 1, 'color', 'b', 'lineStyle', '-.');
line([p1(1) tb(1)], [p1(2) tb(2)], [p1(3) tb(3)], 'lineWidth', 1, 'color', 'b', 'lineStyle', '-.');

na = p1 - ta;
na = na / norm(na);
nb = p1 - tb;
nb = nb / norm(nb);

alpha = norm(cross(sb - sa, nb)) / norm(cross(na, nb));
q = sa + alpha * na;

scatter3(q(1), q(2), q(3), 70, 'filled', 'r');









