function [F, Jc, Jr] = compute_energy6(centers, radii, tangent_blocks, tangent_spheres, verbose)

D = length(centers{1});

%% Compute projection on the triangle plane
    F = zeros(D * length(tangent_blocks), 1);
    Jc = zeros(D * length(tangent_blocks), length(centers) * D);
    Jr = zeros(D * length(tangent_blocks), length(centers));
    
    for i = 1:length(tangent_blocks);
        if verbose && (iter == 1 || iter == num_iters)
            display_result(centers, [], [],tangent_blocks(i), radii, false, 0.7, 'small');
            display_result(centers, [], [], {tangent_spheres(i)}, radii, false, 0.7, 'none');
        end
        
        %% Sphere data
        c = centers{tangent_spheres(i)}; r = radii{tangent_spheres(i)};
        sphere_gradients = get_parameters_gradients(tangent_spheres(i), cell(length(centers)), D, 'fitting');
        block_gradients = get_parameters_gradients(tangent_blocks{i}, cell(length(centers)), D, 'fitting');
        
        %% Compute projection
        c1 = centers{tangent_blocks{i}(1)}; r1 = radii{tangent_blocks{i}(1)};
        c2 = centers{tangent_blocks{i}(2)}; r2 = radii{tangent_blocks{i}(2)};
        c3 = centers{tangent_blocks{i}(3)}; r3 = radii{tangent_blocks{i}(3)};
        
        [v1, ~, ~, u1, u2, u3, n, n2, block_gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, block_gradients);       
        
        % Rename if required
        [t1] = project_point_on_plane(c, v1, n);
        [t2] = project_point_on_plane(c, u1, n2);
        if norm(c - t2) < norm(c - t1)
            v1 = u1; v2 = u2; v3 = u3; n = n2;
            for var = 1:length(block_gradients)
                block_gradients{var}.dv1 = block_gradients{var}.du1;
                block_gradients{var}.dn1 = block_gradients{var}.dn2;
            end
        end
        
        gradients = [block_gradients, sphere_gradients];
        for var = 1:length(gradients)
            if var <= length(block_gradients)
                dv1 = gradients{var}.dv1;
                dn = gradients{var}.dn1;
                dc = zeros(D, size(dv1, 2));
                dr = zeros(1, size(dv1, 2));
            else
                dc = gradients{var}.dc1;
                dr = gradients{var}.dr1;
                %dr = zeros(1, size(dc, 2));
                dv1 = zeros(D, size(dc, 2));
                dn = zeros(D, size(dc, 2));
            end
            
            % d = (c - v1)' * n1
            [O1, dO1] = difference_derivative(c, dc, v1, dv1);
            [d, dd] = dot_derivative(O1, dO1, n, dn);
            
            % t = c - n1 * d
            [O1, dO1] = product_derivative(d, dd, n, dn);
            [q, dq] = difference_derivative(c, dc, O1, dO1);
            
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
        if verbose && (iter == 1 || iter == num_iters)
            mypoint(c, 'r'); mypoint(q, 'm'); myline(c, q, 'c');
            draw_plane(q, n, 'c', centers);
        end
    end