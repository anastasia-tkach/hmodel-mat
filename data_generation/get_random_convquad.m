function [centers, radii, blocks] = get_random_convquad()
D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1); c4 = rand(D, 1);
    r1 = 0.1 * rand(1, 1); r2 = 0.1 * rand(1, 1); r3 = 0.1 * rand(1, 1); r4 = 0.1 * rand(1, 1);
    
    blocks = {[1, 2, 3], [2, 3, 4]};
    radii = {r1, r2, r3, r4};
    centers = {c1, c2, c3, c4};
    
    [blocks] = reindex(radii, blocks);
    
    valid_convtriangle = true;    
    
    for b = 1:length(blocks)
        c1 = centers{blocks{b}(1)}; r1 = radii{blocks{b}(1)};
        c2 = centers{blocks{b}(2)}; r2 = radii{blocks{b}(2)};
        c3 = centers{blocks{b}(3)}; r3 = radii{blocks{b}(3)};
        
        has_tangent_cone1 = verify_tangent_cone(c1, c2, r1, r2);
        has_tangent_cone2 = verify_tangent_cone(c2, c3, r2, r3);
        has_tangent_cone3 = verify_tangent_cone(c1, c3, r1, r3);
        
        has_tangent_plane1 = verify_tangent_plane(c1, c2, c3, r1, r2, r3);
        has_tangent_plane2 = verify_tangent_plane(c1, c3, c2, r1, r3, r2);
        has_tangent_plane3 = verify_tangent_plane(c2, c3, c1, r2, r3, r1);
        
        if ~has_tangent_cone1 || ~has_tangent_cone2 || ~has_tangent_cone3 || ...
                ~has_tangent_plane1 || ~has_tangent_plane2 || ~has_tangent_plane3
            valid_convtriangle = true;
        end
    end
    
    if valid_convtriangle, break; end
    disp('invalid configuration');
end
disp('valid configuration');


