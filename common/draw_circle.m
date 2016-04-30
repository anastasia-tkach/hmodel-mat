function [] = draw_circle(center, radius, color, varargin)

line_width = 2;
if ~isempty(varargin)
    line_width = varargin{1};
end

NOP = 100;

THETA = linspace(0, 2 * pi, NOP);
RHO = ones(1,NOP) * radius;
[X,Y] = pol2cart(THETA,RHO);
X = X + center(1);
Y = Y + center(2);
plot(X, Y, 'lineWidth', line_width, 'color', color);
