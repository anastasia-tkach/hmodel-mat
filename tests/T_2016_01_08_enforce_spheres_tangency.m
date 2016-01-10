

clear all; close all; clc;
D = 3;

% [tri_centers, tri_radii, tri_blocks] = get_random_convtriangle();
% [seg_centers, seg_radii, seg_blocks] = get_random_convsegment(D);
% centers = [tri_centers; seg_centers];
% radii = [tri_radii; seg_radii];
% blocks = {[1, 2, 3], [4, 5]};

data_path = '_data/my_hand/initialized/';
load([data_path, 'named_blocks.mat']);
load([data_path, 'names_map.mat']);
results_path = '_data/my_hand/fitted_model/';
load([results_path, 'centers.mat']);
load([results_path, 'radii.mat']);
load([results_path, 'blocks.mat']);
display_result(centers, [], [], blocks, radii, false, 1, 'big');
named_tangent_blocks = {};
named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};

named_tangent_spheres = {};
named_tangent_spheres{end + 1} = 'pinky_base';
named_tangent_spheres{end + 1} = 'ring_base';
named_tangent_spheres{end + 1} = 'ring_base';
named_tangent_spheres{end + 1} = 'middle_base';
named_tangent_spheres{end + 1} = 'middle_base';
named_tangent_spheres{end + 1} = 'index_base';

tangent_blocks = get_smooth_blocks(blocks, named_blocks, named_tangent_blocks);
tangent_spheres = zeros(length(named_tangent_spheres), 1);
for i = 1:length(named_tangent_spheres)
    key = named_tangent_spheres(i);
    tangent_spheres(i) = names_map(key{1});
end

num_iters = 5; history = zeros(num_iters, 1);
for iter = 1:num_iters
    
    %% Compute projection on the triangle plane
    F = zeros(length(tangent_blocks), 1);
    Jc = zeros(length(tangent_blocks), length(centers) * D);
    Jr = zeros(length(tangent_blocks), length(centers));
    
    for i = 1:length(tangent_spheres);
        %if iter == 1 || iter == num_iters
        %    display_result(centers, [], [],tangent_blocks(i), radii, false, 0.7, 'small');
        %    display_result(centers, [], [], {tangent_spheres(i)}, radii, false, 0.7, 'none');
        %end
        
        c1 = centers{tangent_blocks{i}(1)}; c2 = centers{tangent_blocks{i}(2)}; c3 = centers{tangent_blocks{i}(3)};
        r1 = radii{tangent_blocks{i}(1)}; r2 = radii{tangent_blocks{i}(2)}; r3 = radii{tangent_blocks{i}(3)};
        
        c = centers{tangent_spheres(i)}; r = radii{tangent_spheres(i)};
        
        %% Compute gradients
        convtriangle_gradients = get_parameters_gradients(tangent_blocks{i}, cell(length(centers)), D, 'fitting');
        [v1, v2, v3, u1, u2, u3, n1, n2, convtriangle_gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, convtriangle_gradients);
        
        % Rename if required
        [t1] = project_point_on_plane(c, v1, n1);
        [t2] = project_point_on_plane(c, u1, n2);
        if norm(c - t2) < norm(c - t1)
            v1 = u1; v2 = u2; v3 = u3; n1 = n2;
            for var = 1:length(convtriangle_gradients)
                convtriangle_gradients{var}.dv1 = convtriangle_gradients{var}.du1;
                convtriangle_gradients{var}.dn1 = convtriangle_gradients{var}.dn2;
            end
        end
        
        sphere_gradients = get_parameters_gradients(tangent_spheres(i), cell(length(centers)), D, 'fitting');
        gradients = [convtriangle_gradients, sphere_gradients];
        for var= 1:length(gradients)
            if var <= length(convtriangle_gradients)
                dv1 = gradients{var}.dv1;
                dn1 = gradients{var}.dn1;
                dc = zeros(D, size(dv1, 2));
                dr = zeros(1, size(dv1, 2));
             else
                dc = gradients{var}.dc1;
                dr = gradients{var}.dr1;
                dv1 = zeros(D, size(dc, 2));
                dn1 = zeros(D, size(dc, 2));
            end
            
            % d = (c - v1)' * n1
            [O1, dO1] = difference_derivative(c, dc, v1, dv1);
            [d, dd] = dot_derivative(O1, dO1, n1, dn1);
            
            % t = c - n1 * d
            [O1, dO1] = product_derivative(d, dd, n1, dn1);
            [t, dt] = difference_derivative(c, dc, O1, dO1);
            
            % f = (c - t)' * (c - t) - r^2
            [O1, dO1] = difference_derivative(c, dc, t, dt);
            [O2, dO2] = dot_derivative(O1, dO1, O1, dO1);
            [r2, dr2] = product_derivative(r, dr, r, dr);
            [f, df] = difference_derivative(O2, dO2, r2, dr2);
            
            index = gradients{var}.index;
            if numel(df) == D
                Jc(i, D * index - D + 1:D * index) = Jc(i, D * index - D + 1:D * index) + df;
            else
                Jr(i, index) = Jr(i, index) + df;
            end
        end
        
        F(i) = f;
        
        %% Display
        %if iter == 1 || iter == num_iters
        %    myline(v1, v2, 'b'); myline(v2, v3, 'b'); myline(v1, v3, 'b');
        %    mypoint(c, 'r'); mypoint(t, 'm'); myline(c, t, 'c'); myline(v1, t, 'c');
        %    draw_plane(t, n1, 'c', centers);
        %end
    end
    
    J = [Jc, Jr];
    
    disp(F' * F);
    history(iter) = F' * F;
    num_centers = length(centers);
    num_poses = 1;
    damping = 1;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    LHS = damping * I + J' * J;
    rhs = J' * F;
    delta = -  LHS \ rhs;
    poses{1}.centers = centers;
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    centers = poses{1}.centers;
    
    
end
figure; hold on; plot(1:num_iters, history, 'lineWidth', 2);
display_result(centers, [], [], blocks, radii, false, 1, 'big');
