function [] = draw_circle(center, radius, color)

NOP = 100;

THETA = linspace(0, 2 * pi, NOP);
RHO = ones(1,NOP) * radius;
[X,Y] = pol2cart(THETA,RHO);
X = X + center(1);
Y = Y + center(2);
plot(X, Y, 'lineWidth', 2, 'color', color);
