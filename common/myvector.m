function [] = myvector(o, v, f, color)

if length(v) == 3
    line([o(1) o(1) + f * v(1)], [o(2) o(2) + f * v(2)], [o(3) o(3) + f * v(3)], 'lineWidth', 2, 'color', color);
end

if length(v) == 2
    line([o(1) o(1) + f * v(1)], [o(2) o(2) + f * v(2)], 'lineWidth', 2, 'color', color);
end

