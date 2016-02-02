function [result] = is_point_on_segment(a, b, c)
    result = false;
    v = (b - a)' * (c - a);
    if v < 0
        return
    end
    if v > (b - a)' * (b - a);
        return
    end
    result = true;
end