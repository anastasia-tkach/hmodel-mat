function out = convolution_triangle(x, y, z)

num_points = numel(x);
out  = zeros(num_points, 1);

for i = 1:num_points
    p = [x(i); y(i); z(i)];
    c1 = [1, 2, 2]';
    c2 = [3, 1, 3]';
    centers{1} = c1;
    centers{2} = c2;
    r1 = 1;
    r2 = 1.5;
    
    u = c2 - c1;
    v = p - c1;
    
    q = u' * v / (u' * u);
    
    if q <= 0       
        t = c1;
        r = r1;
    end
    if q > 0 && q < 1        
        t = c1 + q * u;
        r = (norm(c2 - t) * r1 + norm(t - c1) * r2) / norm(c2 - c1);
    end
    if q >= 1       
        t = c2;
        r = r2;
    end
    
    out(i) = norm(t - p) - r;
end

out = reshape(out, size(x, 1), size(x, 2), size(x, 3));