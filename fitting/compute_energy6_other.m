function [F, Jc, Jr] = compute_energy6(centers, radii, tangent_blocks, tangent_spheres, verbose)

D = length(centers{1});

%% Compute projection on the triangle plane
F = zeros(D * length(tangent_blocks), 1);
Jc = zeros(D * length(tangent_blocks), length(centers) * D);
Jr = zeros(D * length(tangent_blocks), length(centers));

for i = 1:length(tangent_blocks);
    if verbose
        display_result(centers, [], [], tangent_blocks(i), radii, false, 0.7, 'small');
        display_result(centers, [], [], {tangent_spheres(i)}, radii, false, 0.7, 'none');
    end
    
    %% Sphere data
    c = centers{tangent_spheres(i)}; r = radii{tangent_spheres(i)};
    sphere_gradients = get_parameters_gradients(tangent_spheres(i), cell(length(centers), 1), D, 'fitting');
    block_gradients = get_parameters_gradients(tangent_blocks{i}, cell(length(centers), 1), D, 'fitting');
    
    %% Compute projection
    [indices, projections, ~, axis_projection] = compute_projections_matlab({c}, centers, tangent_blocks(i), radii);
    index = indices{1}; s = axis_projection{1}; q = projections{1};
    is_inside = test_insideness(c, q, s);
    
    if length(index) == 1
        [q, block_gradients] = jacobian_sphere_attachment(q, centers{index(1)}, radii{index(1)}, block_gradients);
    end
    if length(index) == 2
        [q, block_gradients] = jacobian_convsegment_attachment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)}, block_gradients);
    end
    if length(index) == 3
        [tangent_gradients] = jacobian_tangent_planes_attachment(centers, tangent_blocks(i), radii, cell(length(centers), 1), 'fitting');
        tangent_gradient = tangent_gradients{1};
        if (index(1) > 0),
            [q, block_gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, block_gradients, 'v');
        else
            [q, block_gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, block_gradients, 'u');
        end
    end
    
    gradients = [block_gradients, sphere_gradients];
    for var = 1:length(gradients)
        if var <= length(block_gradients)
            dq = gradients{var}.df;
            dc = zeros(D, size(dq, 2));
            dr = zeros(1, size(dq, 2));
        else
            dc = gradients{var}.dc1;
            dr = gradients{var}.dr1;
            dq = zeros(D, size(dc, 2));
        end
        
        % n = (c - q) / norm(c - q);
        if is_inside
            [O1, dO1] = difference_derivative(q, dq, c, dc);
        else
            [O1, dO1] = difference_derivative(c, dc, q, dq);
        end
        [n, dn] = normalize_derivative(O1, dO1);
        
        % f = t - c - r * n
        [O1, dO1] = difference_derivative(q, dq, c, dc);
        [rn, drn] = product_derivative(r, dr, n, dn);
        [f, df] = difference_derivative(O1, dO1, rn, drn);
        
        index = gradients{var}.index;
        if numel(df) == D * D
            Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
        else
            Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
        end
        
    end
    
    F(D * i - D + 1:D * i) = f;
    
    %% Display
    if verbose
        mypoint(c, 'r'); mypoint(q, 'm'); myline(c, q, 'b');
        myvector(c, r * n, 1, 'r');
    end
end