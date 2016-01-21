function [lt1, lt2, rt1, rt2] = get_tangents(c1, c2, r1, r2)

a1 = c1(1);
b1 = c1(2);
a2 = c2(1);
b2 = c2(2);

a21 = a2 - a1;
b21 = b2 - b1;
d2 = a21^2 + b21^2;
r21 = (r2 - r1) / d2;

if d2 - (r2 - r1)^2 < 0
    lt1 = [];
    lt2 = [];
    rt1 = [];
    rt2 = [];
    return
end

s21 = sqrt(d2 - (r2 - r1)^2) / d2; 

u1 = [ - a21 * r21 - b21 * s21;  - b21 * r21 + a21 * s21]; % Left unit vector
u2 = [ - a21 * r21 + b21 * s21;  - b21 * r21 - a21 * s21]; % Right unit vector
lt1 = [a1; b1] + r1 * u1;
lt2 = [a2; b2] + r2 * u1; % Left line tangency points
rt1 = [a1; b1] + r1 * u2; 
rt2 = [a2; b2] + r2 * u2; % Right line tangency points
