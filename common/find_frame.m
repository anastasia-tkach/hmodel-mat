function [F] = find_frame(centers)

a = centers{2} - centers{1};
b = centers{3} - centers{1};

c = cross(a, b);

a = a / norm(a);
b = b / norm(b);
c = c / norm(c);

F = [a, b, c];