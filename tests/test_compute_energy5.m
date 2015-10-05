settings_default;
num_poses = 1;
data_path = '_data/convtriangles/';
load([data_path, 'radii.mat']); load([data_path, 'blocks.mat']);
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;
poses = cell(num_poses, 1);
p = 1;
load([data_path, num2str(p), '_centers.mat']); poses{p}.centers = centers;


D = 3;

factor = 1.5;
%% Compute error
for iter = 1:7
    pose.centers = centers;
    pose.points = [];
    poses{1} = pose;
    display_hand_sketch(poses, radii, blocks, -1);
    
    %display_result_convtriangles(pose, blocks, radii, false);
    
    num_constaints = 3;
    F  = zeros(num_constaints, 1);
    Jc = zeros(num_constaints, length(centers) * D);
    Jr = zeros(num_constaints, length(centers));
    
    %% Compute gradients
    count = 1;
    for b = 1:length(blocks)
        %% Tangent cone
        indices = nchoosek(blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        for i = 1:length(index1)
            [r1, max_index] = max([radii{index1(i)}, radii{index2(i)}]);
            [r2, min_index] = min([radii{index1(i)}, radii{index2(i)}]);
            indices = [index1(i), index2(i)]; i1 = indices(max_index); i2 = indices(min_index);
            c1 = centers{i1}; c2 = centers{i2};
            if norm(c1 - c2) - factor * (r1 - r2) > 0,
                continue;
            end
            [f, df] = jacobian_tangent_cone_existence(c1, c2, r1, r2, factor, {'c1', 'c2', 'r1', 'r2'});
            F(count) = f;
            Jc(count, D * i1 - D + 1:D * i1) = df.dc1;
            Jc(count, D * i2 - D + 1:D * i2) = df.dc2;
            Jr(count, i1) = df.dr1;
            Jr(count, i2) = df.dr2;
            count = count + 1;
        end
        
        %% Tangent plane
        if length(blocks{b}) == 3
            indices = nchoosek(blocks{b}, 2);
            index1 = indices(:, 1);
            index2 = indices(:, 2);
            for i = 1:length(index1)
                [r1, max_index] = max([radii{index1(i)}, radii{index2(i)}]);
                [r2, min_index] = min([radii{index1(i)}, radii{index2(i)}]);
                indices = [index1(i), index2(i)]; i1 = indices(max_index); i2 = indices(min_index);
                i3 = sum([blocks{b}(1), blocks{b}(2), blocks{b}(3)]) - i1 - i2; r3 = radii{i3};                 
                c1 = centers{i1}; c2 = centers{i2}; c3 = centers{i3};
                
                %% Compute objective function
                z = c1 + (c2 - c1) * r1 / (r1 - r2);
                gamma = (c2 - c1)' * (c3 - c1) / ((c2 - c1)' * (c2 - c1)); t = c1 + gamma * (c2 - c1);
                if (t - c1)' * (z - c1) > 0 && norm(t - c1) > norm(z - c1), t = c1 + (z - c1) + (z - t); end
                delta_r = norm(c2 - t) * (r1 - r2) / norm(c2 - c1);
                if (t - c1)' * (c2 - c1) > 0 && norm(t - c1) > norm(c2 - c1), delta_r = -delta_r; end
                r_tilde = delta_r + r2; beta = asin((r1 - r2) / norm(c2 - c1));
                r = r_tilde/cos(beta); eta = r3 + norm(c3 - t); f = eta - factor * r;
                disp(f);
                if f > 0, continue; end
                
                %% Compute gradient                
                [f, df] = jacobian_tangent_plane_existence(c1, c2, c3, r1, r2, r3, factor, {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'});
                F(count) = f;
                Jc(count, D * i1 - D + 1:D * i1) = df.dc1;
                Jc(count, D * i2 - D + 1:D * i2) = df.dc2;
                Jc(count, D * i3 - D + 1:D * i3) = df.dc3;
                Jr(count, i1) = df.dr1;
                Jr(count, i2) = df.dr2;
                Jr(count, i3) = df.dr3;
                count = count + 1;
            end
        end
    end
    
    J = [Jc, Jr];
    
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    
    delta = - ((J' * J) + I ) \ (J' * F);
    
    for o = 1:num_centers
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    for o = 1:num_centers
        radii{o} = radii{o} + delta(D * num_centers + o);
    end
    
    
    disp(['energy = ', num2str(F' * F)]);
    
    
end





