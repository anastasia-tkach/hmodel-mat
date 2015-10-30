function [max_p, surface_p, max_q, surface_q] = get_collision_constraints_convsegments(centers, radii, index1, index2)

points = sample_skeleton(centers, {index1});
max_penetration = - 1e10;
max_p = []; max_q = [];

for i = 1:length(points)
    p = points{i};
    q = project_point_on_segment(p, centers{index2(1)}, centers{index2(2)});
    rp = get_convolution_radius_at_points(centers, radii, index1, [], p);
    rq = get_convolution_radius_at_points(centers, radii, index2, [], q);
    %myline(q, p, [0.75, 0.75, 0.75]);
    %if rp + rq > norm(p - q)
        %myline(p, q, [1, 0.4, 1]);
    %else
        %myline(p, p + rp * (q - p) / norm(q - p), 'g');
        %myline(q, q + rq * (p - q) / norm(p - q), 'g');
    %end
    if max_penetration < (rp + rq) - norm(p - q);
        max_penetration = (rp + rq) - norm(p - q);
        surface_p = p + rp * (q - p)/norm(q - p);
        surface_q = q + rq * (p - q)/norm(p - q);
        max_p = p; max_q = q;
    end
end