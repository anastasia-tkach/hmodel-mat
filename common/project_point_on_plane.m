function [t] = project_point_on_plane(p, p0, n)


distance = (p - p0)' * n;
t = p - n * distance;