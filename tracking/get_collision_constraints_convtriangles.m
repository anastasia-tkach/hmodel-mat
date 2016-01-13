function [max_p, surface_p, max_q, surface_q, is_colliding] = get_collision_constraints_convtriangles(centers, radii, index1, index2, tangent_points)

max_penetration = - 1e10;
max_p = []; max_q = []; max_rp = []; max_rq = [];

if length(index1) == 2
    indices1 = {index1};
end
if length(index1) == 3
    indices = nchoosek(index1, 2);
    indices1 = {[indices(1, :)], [indices(2, :)], [indices(3, :)]};
end
if length(index2) == 2
    normal2 = [];
end
if length(index2) == 3
    normal2 = (centers{index2(1)} - tangent_points.v1)/norm(centers{index2(1)} - tangent_points.v1);
end

for j = 1:length(indices1)
    points = sample_skeleton(centers, {indices1{j}});
    for i = 1:length(points)
        p = points{i};
        
        if length(index2) == 2
            q = project_point_on_segment(p, centers{index2(1)}, centers{index2(2)});
        end
        if length(index2) == 3
            q = project_point_on_triangle(p, centers{index2(1)}, centers{index2(2)}, centers{index2(3)});
        end
        
        rp = get_convolution_radius_at_points(centers, radii, indices1{j}, [], p);
        rq = get_convolution_radius_at_points(centers, radii, index2, normal2, q);
        
        if max_penetration < (rp + rq) - norm(p - q);
            max_penetration = (rp + rq) - norm(p - q);
            max_p = p; max_q = q;
            max_rp = rp; max_rq = rq;
        end
        
        %% Display
        %myline(q, p, [0.75, 0.75, 0.75]);
        %if rp + rq > norm(p - q)
        %    myline(p, q, [1, 0.4, 1]);
        %else
        %    myline(p, p + rp * (q - p) / norm(q - p), 'g');
        %    myline(q, q + rq * (p - q) / norm(p - q), 'g');
        %end
        
    end
end

if max_penetration > 5e-2
    is_colliding = true;
    %disp(max_penetration);
else
    is_colliding = false; 
end

surface_p = max_p + max_rp * (max_q - max_p)/norm(max_q - max_p);
surface_q = max_q + max_rq * (max_p - max_q)/norm(max_p - max_q);

% if length(index1) == 3
%     [~, surface_p, ~] = compute_projections({max_p + 1e-5 * (max_q - max_p)}, centers, {index2}, radii);
%     surface_p = surface_p{1};
% end
% if length(index2) == 3
%     [~, surface_q, ~] = compute_projections({max_q + 1e-5 * (max_p - max_q)}, centers, {index1}, radii);
%     surface_q = surface_q{1};
% end
