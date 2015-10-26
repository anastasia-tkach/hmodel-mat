function [p, surface_p, q, surface_q] = get_collision_constraints_convsegments(centers, radii, index1, index2)

c1 = centers{index1(1)}; c2 = centers{index1(2)};
c3 = centers{index2(1)}; c4 = centers{index2(2)};
r1 = radii{index1(1)}; r2 = radii{index1(2)};
r3 = radii{index2(1)}; r4 = radii{index2(2)};

points = sample_skeleton({c1; c2}, {[1, 2]});
max_penetration = - 1e10;

for i = 1:length(points)
    p = points{i};
    q = project_point_on_segment(p, c3, c4);
    rp = get_convolution_radius_at_points({c1; c2}, {r1; r2}, [1, 2], p);
    rq = get_convolution_radius_at_points({c3; c4}, {r3; r4}, [1, 2], q);
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
    end
end