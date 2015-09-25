%% Generate input
clc
N = 7;
while(true)
    c1 = 0.5 * rand(2 ,1);
    c2 = 0.5 * rand(2 ,1);
    x1 = rand(1 ,1);
    x2 = rand(1 ,1);
    r1 = max(x1, x2);
    r2 = min(x1, x2);
    P = rand(2, N);
    if norm(c1 - c2) > r1
        break;
    end
end
distances = zeros(N, 1);
%% Compute
for i = 1:N
    p = P(:, i);
    
    u = c2 - c1;
    v = p - c1;
    
    alpha = u' * v / (u' * u);
    t = c1 + alpha * u;
    
    omega = sqrt(u' * u - (r1 - r2)^2);
    delta =  norm(p - t) * (r1 - r2) / omega;
    
    done = false;
    
    if alpha <= 0
        s = c1;
        q =  c1 + r1 * (p - c1) / norm(p - c1);
        done  = true;
    end
    if (alpha > 0 && alpha < 1)
        if (norm(c1 - t) < delta)
            s = c1;
            q = c1 + r1 * (p - c1) / norm(p - c1);
            done  = true;
        end
    end
    if (alpha >= 1)
        if (norm(t - c2) > delta)
            s = c2;
            q = c2 + r2 * (p - c2) / norm(p - c2);
            done  = true;
        end
        if norm(c1 - c2) < delta
            s = c1;
            q =  c1 + r1 * (p - c1) / norm(p - c1);
            done  = true;
        end
    end
    
    if done == false
        s = t - delta * (c2 - c1) / norm(c2 - c1);
        gamma = (r1 - r2) * norm(c2 - t + delta * u / norm(u))/ sqrt(u' * u);
        q = s + (p - s) / norm(p - s) * (gamma + r2);
    end
    
    if (norm(p - s) >= norm(q - s))
        d = norm(p - q);
    else
        d = - norm(p - q);
    end
    distances(i) = d;
end

%% Call mex
out = compute_distances_to_model(c1, c2, r1, r2, P);

[distances, out]