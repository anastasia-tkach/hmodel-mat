function [centers, radii, blocks] = get_random_convsegment()

D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1);
    x1 = rand(1, 1); x2 = rand(1, 1); 
    r1 = max(x1, x2); r2  = min(x1, x2);
    if norm(c1 - c2) > r1 + r2
        break;
    end
end
centers = {c1; c2};
radii = {r1; r2};
blocks = {[1, 2]};