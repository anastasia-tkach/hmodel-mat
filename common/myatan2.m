function [alpha] = myatan2(v)

alpha = atan2(v(2), v(1));

if alpha < 0
    alpha = alpha + 2 * pi;
end

% if verbose
%     disp(alpha * 180 / pi)
% end