clear; close all; clc;
D = 3;

% Synthetic data

[tri_centers, tri_radii, tri_blocks] = get_random_convtriangle();
[seg_centers, seg_radii, seg_blocks] = get_random_convsegment(D);
centers = [tri_centers; seg_centers];
radii = [tri_radii; seg_radii];
blocks = {[1, 2, 3], [4, 5]};
tangent_blocks{1} = [1, 2, 3];
tangent_spheres(1) = 4;
initial_centers = centers;
initial_radii = radii;

centers = initial_centers;
radii = initial_radii;
%% Hand data
data_path = '_data/my_hand/initialized/';
load([data_path, 'tangent_spheres.mat']);
load([data_path, 'tangent_blocks.mat']);
results_path = '_data/my_hand/fitted_model/';
%load([results_path, 'centers.mat']);
load centers5 centers5; centers = centers5;
load([results_path, 'radii.mat']);
load([results_path, 'blocks.mat']);
%display_result(centers, [], [], blocks, radii, false, 1, 'big');

verbose = false;
num_iters = 20; history = zeros(num_iters, 1);

for iter = 1:num_iters
    
%     %% Compute projection on the triangle plane
%     F = zeros(D * length(tangent_blocks), 1);
%     Jc = zeros(D * length(tangent_blocks), length(centers) * D);
%     Jr = zeros(D * length(tangent_blocks), length(centers));
%     
%     for i = 1:length(tangent_spheres);
%         if verbose && (iter == 1 || iter == num_iters)
%             display_result(centers, [], [], tangent_blocks(i), radii, false, 0.7, 'small');
%             display_result(centers, [], [], {tangent_spheres(i)}, radii, false, 0.7, 'none');
%         end
%         
%         %% Sphere data
%         c = centers{tangent_spheres(i)}; r = radii{tangent_spheres(i)};
%         sphere_gradients = get_parameters_gradients(tangent_spheres(i), cell(length(centers), 1), D, 'fitting');
%         block_gradients = get_parameters_gradients(tangent_blocks{i}, cell(length(centers), 1), D, 'fitting');
%         
%         %% Compute projection
%         [indices, projections, ~, axis_projection] = compute_projections_matlab({c}, centers, tangent_blocks(i), radii);
%         index = indices{1}; s = axis_projection{1}; q = projections{1};
%         is_inside = test_insideness(c, q, s);
%         
%         if length(index) == 1
%             [q, block_gradients] = jacobian_sphere_attachment(q, centers{index(1)}, radii{index(1)}, block_gradients);
%         end
%         if length(index) == 2
%             [q, block_gradients] = jacobian_convsegment_attachment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)}, block_gradients);
%         end
%         if length(index) == 3
%             [tangent_gradients] = jacobian_tangent_planes_attachment(centers, tangent_blocks(i), radii, cell(length(centers), 1), 'fitting');
%             tangent_gradient = tangent_gradients{1};
%             if (index(1) > 0),
%                 [q, block_gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, block_gradients, 'v');
%             else
%                 [q, block_gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, block_gradients, 'u');
%             end
%         end
%         
%         gradients = [block_gradients, sphere_gradients];
%         for var = 1:length(gradients)
%             if var <= length(block_gradients)
%                 dq = gradients{var}.df;
%                 dc = zeros(D, size(dq, 2));
%                 dr = zeros(1, size(dq, 2));
%             else
%                 dc = gradients{var}.dc1;
%                 dr = gradients{var}.dr1;
%                 dq = zeros(D, size(dc, 2));
%             end
%             
%             % n = (c - q) / norm(c - q);
%             if is_inside
%                 [O1, dO1] = difference_derivative(q, dq, c, dc);
%             else
%                 [O1, dO1] = difference_derivative(c, dc, q, dq);
%             end
%             [n, dn] = normalize_derivative(O1, dO1);
%             
%             % f = t - c - r * n
%             [O1, dO1] = difference_derivative(q, dq, c, dc);
%             [rn, drn] = product_derivative(r, dr, n, dn);
%             [f, df] = difference_derivative(O1, dO1, rn, drn);
%             
%             index = gradients{var}.index;
%             if numel(df) == D * D
%                 Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
%             else
%                 Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
%             end
%             
%         end
%         
%         F(D * i - D + 1:D * i) = f;
%         
%         %% Display
%         if verbose && (iter == 1 || iter == num_iters)
%             mypoint(c, 'r'); mypoint(q, 'm'); myline(c, q, 'b');
%             myvector(c, r * n, 1, 'r');
%         end
%     end
    
    [F, Jc, Jr] = compute_energy6(centers, radii, tangent_blocks, tangent_spheres, false);
    J = [Jc, Jr];
    
    disp(F' * F);
    history(iter) = F' * F;
    num_centers = length(centers);
    num_poses = 1;
    damping = 10;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    LHS = damping * I + J' * J;
    rhs = J' * F;
    delta = -  LHS \ rhs;
    poses{1}.centers = centers;
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    centers = poses{1}.centers;
    
    
end
figure; hold on; plot(1:num_iters, history, 'lineWidth', 2);
display_result(centers, [], [], blocks, radii, false, 1, 'big');
