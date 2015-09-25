function [distances] = tangent_distance(X, Y, Z, c1, c2, r1, r2)

N = numel(X);
points = [reshape(X, N, 1), reshape(Y, N, 1), reshape(Z, N, 1)];
distances = zeros(N, 1);

for i = 1:N
    p = points(i, :)';
    indices = [];
    
    u = c2 - c1;
    v = p - c1;
    
    alpha = u' * v / (u' * u);
    t = c1 + alpha * u;
    
    omega = sqrt(u' * u - (r1 - r2)^2);
    delta =  norm(p - t) * (r1 - r2) / omega;
    
    if alpha <= 0
        s = c1;
        q =  c1 + r1 * (p - c1) / norm(p - c1);
        indices = [1];
    end
    if (alpha > 0 && alpha < 1)
        if (norm(c1 - t) < delta)
            s = c1;
            q = c1 + r1 * (p - c1) / norm(p - c1);
            indices = [1];
        end
    end
    if (alpha >= 1)
        if (norm(t - c2) > delta)
            s = c2;
            q = c2 + r2 * (p - c2) / norm(p - c2);
            indices = [2];
        end
        if norm(c1 - c2) < delta
            s = c1;
            q =  c1 + r1 * (p - c1) / norm(p - c1);
            indices = [2];
        end
    end
    
    if isempty(indices)
        s = t - delta * (c2 - c1) / norm(c2 - c1);
        gamma = (r1 - r2) * norm(c2 - t + delta * u / norm(u))/ sqrt(u' * u);
        q = s + (p - s) / norm(p - s) * (gamma + r2);
        indices = [1, 2];
    end
    if (norm(p - s) >= norm(q - s))
        distances(i) = norm(p - q);
    else
        distances(i) = - norm(p - q);
    end
end
distances = reshape(distances, size(X));

