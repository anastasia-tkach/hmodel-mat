function [] = draw_tangents(R, C, color)

r1 = R(1);
r2 = R(2);
a1 = C(1, 1);
b1 = C(1, 2);
a2 = C(2, 1);
b2 = C(2, 2);

a21 = a2-a1;
b21 = b2-b1;
d2 = a21^2+b21^2;
r21 = (r2-r1)/d2;
s21 = sqrt(d2-(r2-r1)^2)/d2; % <-- If d2<(r2-r1)^2, no solution is possible
u1 = [-a21*r21-b21*s21,-b21*r21+a21*s21]; % Left unit vector
u2 = [-a21*r21+b21*s21,-b21*r21-a21*s21]; % Right unit vector
L1 = [a1,b1]+r1*u1;
L2 = [a2,b2]+r2*u1; % Left line tangency points
R1 = [a1,b1]+r1*u2; 
R2 = [a2,b2]+r2*u2; % Right line tangency points
line([L1(1) L2(1)], [L1(2) L2(2)], 'lineWidth', 2, 'color', color);
line([R1(1) R2(1)], [R1(2) R2(2)], 'lineWidth', 2, 'color', color);