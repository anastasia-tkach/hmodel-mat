function [] = myline(a, b, color)

if length(a) == 3
    line([a(1) b(1)], [a(2) b(2)], [a(3) b(3)], 'lineWidth', 2, 'color', color);
end

if length(a) == 2
    line([a(1) b(1)], [a(2) b(2)], 'lineWidth', 2, 'color', color);
end