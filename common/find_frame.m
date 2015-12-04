function [F] = find_frame(centers, factor)

a = centers{2} - centers{1};
b = centers{3} - centers{1};

c = cross(a, b);

a = a / norm(a);
b = b / norm(b);
c = c / norm(c);

F = [a, b, c];

%% Display frame
if factor
myline(centers{1}, centers{1} + factor * F(:, 1), 'm');
myline(centers{1}, centers{1} + factor * F(:, 2), 'm');
myline(centers{1}, centers{1} + factor * F(:, 3), 'm');
end