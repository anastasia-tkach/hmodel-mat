function [centers, radii, blocks] = get_random_sphere()

D = 3;
c = rand(D, 1);
r = 0.4 * rand(1, 1);
centers = {c};
radii = {r};
blocks = {[1]};