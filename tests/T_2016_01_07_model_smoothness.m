close all; clear; clc;
D = 3;
num_samples = 1000;
epsilon = 0.01;
[centers, radii, blocks] = get_random_convquad();

initial_centers = centers;
initial_radii = radii;

close all;
centers = initial_centers;
radii = initial_radii;

num_iters = 10;
history = zeros(num_iters, 1);

for iter = 1:num_iters
    
    if iter == 1 || iter == 10
        display_result(centers, [], [], blocks, radii, false, 1);
    end
    
    variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};
    tangent_gradients = cell(length(blocks), 1);
    blocks_normals = cell(length(blocks), 1);
    
    for i = 1:length(blocks)
        
        if length(blocks{i}) == 3
            c1 = centers{blocks{i}(1)};
            c2 = centers{blocks{i}(2)};
            c3 = centers{blocks{i}(3)};
            
            r1 = radii{blocks{i}(1)};
            r2 = radii{blocks{i}(2)};
            r3 = radii{blocks{i}(3)};
            
            attachments = cell(length(centers));
            gradients = get_parameters_gradients(blocks{i}, attachments, D);
            gradient.dc1 = zeros(D, 1); gradient.dc2 = zeros(D, 1); gradient.dc3 = zeros(D, 1);
            gradient.dr1 = 0; gradient.dr2 = 0; gradient.dr3 = 0;
            gradients{4} = gradient; gradients{4}.dr1 = 1; gradients{4}.index = blocks{i}(4 - 3);
            gradients{5} = gradient; gradients{5}.dr2 = 1; gradients{5}.index = blocks{i}(5 - 3);
            gradients{6} = gradient; gradients{6}.dr3 = 1; gradients{6}.index = blocks{i}(6 - 3);
            
            [v1, v2, v3, u1, u2, u3, n1, n2, gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, gradients);
            tangent_gradients{i}.gradients = gradients;
            tangent_gradients{i}.n1 = n1; tangent_gradients{i}.n2 = n2;
        end
    end
    
    %% Rename the normals
    first_blocks = cell(0, 1);
    second_blocks = cell(0, 1);
    count = 1;
    for a = 1:length(blocks)
        for b = a + 1:length(blocks)
            if sum(ismember(blocks{a}, blocks{b})) ~= 2, continue; end
            if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n1) > 0.5
                %% First pair
                first_blocks{count}.n = tangent_gradients{a}.n1;
                second_blocks{count}.n = tangent_gradients{b}.n1;
                for var = 1:length(tangent_gradients{b}.gradients)
                    first_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn1;
                    second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;
                    first_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;
                    second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                end
                count = count + 1;
                %% Second pair
                first_blocks{count}.n = tangent_gradients{a}.n2;
                second_blocks{count}.n = tangent_gradients{b}.n2;
                for var = 1:length(tangent_gradients{b}.gradients)
                    first_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn2;
                    second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;
                    first_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;
                    second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                end
                count = count + 1;
            end
            if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n2) > 0.5
                %% First pair
                first_blocks{count}.n = tangent_gradients{a}.n1;
                second_blocks{count}.n = tangent_gradients{b}.n2;
                for var = 1:length(tangent_gradients{b}.gradients)
                    first_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn1;
                    second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;
                    first_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;
                    second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                end
                count = count + 1;
                %% Second pair
                first_blocks{count}.n = tangent_gradients{a}.n2;
                second_blocks{count}.n = tangent_gradients{b}.n1;
                for var = 1:length(tangent_gradients{b}.gradients)
                    first_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn2;
                    second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;
                    first_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;
                    second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                end
                count = count + 1;
            end
            if count > 1
                if iter == 1 || iter == 10
                    ia = blocks{a}(~ismember(blocks{a}, blocks{b}));
                    ib = blocks{b}(~ismember(blocks{b}, blocks{a}));
                    myvector(centers{ia}, first_blocks{count - 1}.n, 0.3, 'r');
                    myvector(centers{ib},second_blocks{count - 1}.n, 0.3, 'r');
                    myvector(centers{ia}, first_blocks{count - 2}.n, 0.3, 'b');
                    myvector(centers{ib},second_blocks{count - 2}.n, 0.3, 'b');
                end
            end
        end
    end
    if isempty(first_blocks), break; end
    
    %% Visualize triangles
    count = 1;
    
    F = zeros(length(first_blocks), 1);
    Jc = zeros(length(first_blocks), length(centers) * D);
    Jr = zeros(length(first_blocks), length(centers));
    
    for i = 1:length(first_blocks)
        n = first_blocks{i}.n;
        m = second_blocks{i}.n;
        df = cell(0, 1);
        one = 1;
        for var = 1:length(first_blocks{i}.dn)
            dn = first_blocks{i}.dn{var};
            dm = zeros(size(dn));
            d_one = zeros(1, size(dn, 2));
            [o, do] = dot_derivative(n, dn, m, dm);
            [o, do] = sqrt_derivative(o, do);
            [q, dq] = difference_derivative(one, d_one, o, do);
            df{var} = dq;
        end
        
        dg = cell(0, 1);
        for var = 1:length(second_blocks{i}.dn)
            dm = second_blocks{i}.dn{var};
            dn = zeros(size(dm));
            d_one = zeros(1, size(dn, 2));
            [o, do] = dot_derivative(n, dn, m, dm);
            [o, do] = sqrt_derivative(o, do);
            [q, dq] = difference_derivative(one, d_one, o, do);
            dg{var} = dq;
        end
        
        %% Fill in the Jacobian
        F(i) = q;
        for j = 1:length(df)
            index = first_blocks{i}.index{j};
            if length(df{j}) == 3
                Jc(i, D * index - D + 1:D * index) = Jc(i, D * index - D + 1:D * index) + df{j};
            else
                Jr(i, index) = Jr(i, index) + df{j};
            end
        end
        for j = 1:length(dg)
            index = second_blocks{i}.index{j};
            if length(dg{j}) == 3
                Jc(i, D * index - D + 1:D * index) = Jc(i, D * index - D + 1:D * index) + df{j};
            else
                Jr(i, index) = Jr(i, index) + dg{j};
            end
        end
    end
    J = [Jc, Jr];
    
    disp(F' * F);
    history(iter) = F' * F;
    num_centers = length(centers);
    num_poses = 1;
    damping = 0.0001;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    LHS = damping * I + J' * J;
    rhs = J' * F;
    delta = -  LHS \ rhs;
    poses{1}.centers = centers;
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    centers = poses{1}.centers;
    
end
figure; hold on; plot(1:num_iters, history, 'lineWidth', 2);