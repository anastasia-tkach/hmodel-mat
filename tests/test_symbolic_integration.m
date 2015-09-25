r = 1;
h = 2;
c = 1;

syms x;
syms y;
syms z;
z_min = 1/c * (x^2 + y^2)^0.5;
y_min = (r^2 - x^2)^0.5;
x_min = 0.7 * r;
x_max = r;
I = int(int(int(1, z, z_min, h), y, y_min, r), x, x_min, x_max);
I1 = int((x^2*log((1 - x^2)^(1/2) + 1))/2 - (x^2*log((x^2 + 1)^(1/2) + 1))/2 - (3*(1 - x^2)^(1/2))/2 - (x^2 + 1)^(1/2)/2 + 2, x, 7/10, 1);