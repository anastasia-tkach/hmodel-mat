function [] = myvector(o, v, f, color, varargin)

line_width = 2;
if ~isempty(varargin)
    line_width = varargin{1};
end

if length(v) == 3
    line([o(1) o(1) + f * v(1)], [o(2) o(2) + f * v(2)], [o(3) o(3) + f * v(3)], 'lineWidth', line_width, 'color', color);
end

if length(v) == 2
    line([o(1) o(1) + f * v(1)], [o(2) o(2) + f * v(2)], 'lineWidth', line_width, 'color', color);
end

