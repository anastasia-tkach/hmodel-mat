function [s, n, t, delta] = compute_correction(c1, c2, r1, r2, p)

u = (c2 - c1);
v = p - c1;
alpha = u' * v / (u' * u);
t = c1 + alpha * u;
omega = sqrt(u' * u - (r1 - r2)^2);
delta =  norm(p - t) * (r1 - r2) / omega;
s = t - delta * (c2 - c1) / norm(c2 - c1);

n = p - t;
n = n / norm(n);

my_line(c2, c1 + n * (r1 - r2), 'y');
my_line(s, p, 'y');
my_line(c1, c1 + n * (r1 - r2), 'g');

