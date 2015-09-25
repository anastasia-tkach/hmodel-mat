D = 3;
clc;
% while(true)
%     c1 = rand(D, 1);
%     c2 = rand(D, 1);
%     c3 = rand(D, 1);
%     x1 = rand(1, 1);
%     x2 = rand(1, 1);
%     x3 = rand(1, 1);
%     x = [x1, x2, x3];
%     [r1, i1] = max(x);
%     [r3, i3] = min(x);
%     x([i1, i3]) = 0;
%     r2 = max(x);
%     if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
%         break;
%     end
% end
%p = rand(D, 1);
N = length(wrong_points);
P = wrong_points';
% P = wrong_points(1, :)';
% N = 1;
% N = 50;
% P = rand(D, N);
distances = zeros(N, 1);

%% Find the tangent plane
z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
z13 = c1 + (c3 - c1) * r1 / (r1 - r3);

l = (z12 - z13) / norm(z12 - z13);
projection = (c1 - z12)' * l;
z = z12 + projection * l;

eta = norm(c1 - z);
sin_beta = r1/eta;
j = sqrt(eta^2 - r1^2);
cos_beta = j/eta;

f = (c1 - z) / eta;
h = cross(l, f);
h = h / norm(h);

g = sin_beta * h + cos_beta * f;
v1 = z + j * g;
n = (v1  - c1) / norm(v1  - c1);
v2 = c2 + r2 * n;
v3 = c3 + r3 * n;

g = - sin_beta * h + cos_beta * f;
u1 = z + j * g;
n = (u1  - c1) / norm(u1  - c1);
u2 = c2 + r2 * n;
u3 = c3 + r3 * n;

index1 = 1; index2 = 2; index3 = 3;


%% Compute projection to a convtriangle
for i = 1:N
    
    p = P(:, i);
    
    m = cross(v1 - v2, v1 - v3); m = m / norm(m);
    distance = (p - v1)' * m;
    q1 = p - m * distance;
    is_in_triangle_q1 = is_point_in_triangle(q1, v1, v2, v3);
    
    m = cross(u1 - u2, u1 - u3); m = m / norm(m);
    distance = (p - u1)' * m;
    q2 = p - m * distance;
    is_in_triangle_q2 = is_point_in_triangle(q2, u1, u2, u3);
    
    m = cross(c1 - c2, c1 - c3); m = m / norm(m);
    distance = (p - c1)' * m;
    s = p - m * distance;
    
    I{1} = is_in_triangle_q1; I{2} = is_in_triangle_q2;
    [~, k] = min([norm(q1 - p), norm(q2 - p)]);
    Q{1} = q1; Q{2} = q2; q = Q{k};
    index = I{k};
    
    %% Compute projection to a capsule
    if ~index
        
        %disp('Not in triangle')
        
        [~, q12, s12] = compute_correspondence(p, c1, c2, r1, r2, 0, 0);
        [~, q13, s13] = compute_correspondence(p, c1, c3, r1, r3, 0, 0);
        [~, q23, s23] = compute_correspondence(p, c2, c3, r2, r3, 0, 0);
        
        Q{1} = q12; Q{2} = q23; Q{3} = q13;
        S{1} = s12; S{2} = s23; S{3} = s13;
        
        is_inside = zeros(3, 1);
        temp = zeros(3, 1);
        for j = 1:3
            if norm(p - S{j}) < norm(Q{j} - S{j})
                is_inside(j) = 1;
            end
        end
        
        %% If the point is simultaneously inside two capsules
        if (sum(is_inside) > 1)
            %disp('Two inside');
            if (is_inside(1) == 1 && is_inside(2) == 1 )
                disp('1 & 2');
                [~, q, s] = compute_correspondence(q23, c1, c2, r1, r2, 0, 0);
                if ~test_insideness(q23, q, s)
                    q = q23; s = s23;
                else
                    q = q12; s = s12;
                end
            elseif (is_inside(1) == 1 && is_inside(3) == 1 )
                disp('1 & 3');
                [~, q, s] = compute_correspondence(q13, c1, c2, r1, r2, 0, 0);
                if ~test_insideness(q13, q, s)
                    q = q13; s = s13;
                else
                    q = q12; s = s12;
                end
            elseif (is_inside(2) == 1 && is_inside(3) == 1 )
                disp('2 & 3');
                [~, q, s] = compute_correspondence(q13, c2, c3, r2, r3, 0, 0);
                if ~test_insideness(q13, q, s)
                    q = q13; s = s13;
                else
                    q = q23; s = s23;
                end
            end
            
            %% If point is inside one capsule
        elseif sum(is_inside) == 1
            disp('One inside');
            q = Q{find(is_inside)};
            s = S{find(is_inside)};
            %% If point is outside
        else
            disp('Zero inside');
            [~, k] = min([norm(p - q12), norm(p - q23), norm(p - q13)]);
            q = Q{k};
            s = S{k};
        end
    end
    
    %% Cheek is inside or outside
    if norm(p - s) >= norm(q - s)
        distances(i) = norm(p - q);
    else
        distances(i) = - norm(p - q);
    end
    
    %[~, q_old, s_old, ~] = projection_convtriangle(p, c1, c2, c3, r1, r2, r3, 1, 2, 3);
    %[q'; q_old']
    %[s'; s_old']
    
    
end
%% Call mex
out = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, P);
disp(' ');
[distances, out]


