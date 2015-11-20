function [centers, radii, blocks] = get_random_convtriangle()

D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
    x1 = 0.2 * rand(1, 1); x2 = 0.2 * rand(1, 1); x3 = 0.2 * rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x); [r3, i3] = min(x);
    x([i1, i3]) = 0; r2 = max(x);
    
    has_tangent_cone1 = verify_tangent_cone(c1, c2, r1, r2);
    has_tangent_cone2 = verify_tangent_cone(c2, c3, r2, r3);
    has_tangent_cone3 = verify_tangent_cone(c1, c3, r1, r3);
    
    has_tangent_plane1 = verify_tangent_plane(c1, c2, c3, r1, r2, r3);
    has_tangent_plane2 = verify_tangent_plane(c1, c3, c2, r1, r3, r2);
    has_tangent_plane3 = verify_tangent_plane(c2, c3, c1, r2, r3, r1);
    
    if has_tangent_cone1 && has_tangent_cone2 && has_tangent_cone3 && ...
        has_tangent_plane1 && has_tangent_plane2 && has_tangent_plane3
        break;
    end
    disp('invalid configuration');    
end
disp('valid configuration');
centers = {c1; c2; c3};
radii = {r1; r2; r3};
blocks = {[1, 2, 3]};