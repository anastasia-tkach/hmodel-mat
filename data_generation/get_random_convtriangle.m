function [centers, radii, blocks] = get_random_convtriangle()

D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
    x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x); [r3, i3] = min(x);
    x([i1, i3]) = 0; r2 = max(x);
    if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
        break;
    end
end
centers = {c1; c2; c3};
radii = {r1; r2; r3};
blocks = {[1, 2, 3]};