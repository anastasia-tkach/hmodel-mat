function [] = mypoint(p, color)

if (length(p) == 3)
    scatter3(p(1), p(2), p(3), 8, color, 'o', 'filled');
end
if (length(p) == 2)
    scatter(p(1), p(2), 15, color, 'o', 'filled');
end