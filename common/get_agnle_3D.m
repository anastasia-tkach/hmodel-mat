function [alpha] = get_agnle_3D(a, b, axis)

alpha = atan2(norm(cross(a,b)), dot(a,b));

%% check if we need to reverse the sign
if ~isempty(axis)
    c = rotate_around_axis(axis, a, alpha);
    if norm(b / norm(b) - c / norm(c)) > 10e-10
        alpha = - alpha;
    end
end
