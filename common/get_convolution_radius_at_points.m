function [r] = get_convolution_radius_at_points(centers, radii, indices, normal, p)

if length(indices) == 2
    c1 = centers{indices(1)};
    c2 = centers{indices(2)};
    r1 = radii{indices(1)};
    r2 = radii{indices(2)};
    
    z = c1 + (c2 - c1) * r1 / (r1 - r2);
    r = r1 * norm(z - p) / norm(z - c1);
end

if length(indices) == 3
    c1 = centers{indices(1)};
    c2 = centers{indices(2)};
    c3 = centers{indices(3)};
    r1 = radii{indices(1)};
    r2 = radii{indices(2)};
    r3 = radii{indices(3)};
    
    f = normal' * (c1 - p);
    r = r1 - f;  
    
end