%% Load data
close all; clear; clc;
D = 3;
num_samples = 1000;
epsilon = 0.01;

data_path = '_data/my_hand/initialized/';
load([data_path, 'named_blocks.mat']);
load([data_path, 'smooth_blocks.mat']);
results_path = '_data/my_hand/fitted_model/';
load([results_path, 'centers.mat']);
load([results_path, 'radii.mat']);
load([results_path, 'blocks.mat']);
%display_result(centers, [], [], blocks, radii, false, 1);

%% Describe smooth blocks
% named_smooth_blocks = {};
% named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'};
% named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};
% named_smooth_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
% 
% named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
% named_smooth_blocks{end + 1} = {'palm_right', 'palm_ring', 'palm_back'};
% named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
% named_smooth_blocks{end + 1} = {'palm_middle', 'palm_left', 'palm_back'};
% named_smooth_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'};
% named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
% named_smooth_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'};
% named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};
% 
% named_smooth_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
% named_smooth_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};
% 
% smooth_blocks = cell(0, 1);
% for i = 1:length(named_smooth_blocks)
%     current_name = sort(named_smooth_blocks{i});
%     for index = 1:length(named_blocks)
%         block_name = sort(named_blocks{index});
%         if length(current_name) ~= length(block_name), continue; end
%         is_equal = true;
%         for k = 1:length(current_name)
%             if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
%         end
%         if is_equal == true
%             smooth_blocks{end + 1} = blocks{index};
%             break;
%         end
%     end
% end
%display_invalid_blocks(centers, radii, blocks, smooth_blocks);

%% Optimization
% [centers, radii, blocks] = get_random_convquad();

initial_centers = centers;
initial_radii = radii;

close all;
centers = initial_centers;
radii = initial_radii;

num_iters = 5;
history = zeros(num_iters, 1);

all_blocks = blocks;
blocks = smooth_blocks;

for iter = 1:num_iters
    
    if iter == 1 || iter == num_iters
        display_result(centers, [], [], blocks, radii, false, 1);
        %display_skeleton(centers, radii, blocks, [], false, []);
    end
    

%     tangent_gradients = cell(length(blocks), 1);    
%     for i = 1:length(blocks)
%         
%         if length(blocks{i}) == 3
%             c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)}; c3 = centers{blocks{i}(3)};            
%             r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
%             
%             gradients = get_parameters_gradients(blocks{i}, cell(length(centers)), D, 'fitting');
%             
%             [v1, v2, v3, u1, u2, u3, n1, n2, gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, gradients);
%             tangent_gradients{i}.gradients = gradients;
%             tangent_gradients{i}.n1 = n1; tangent_gradients{i}.n2 = n2;
%         end
%     end
%     
%     %% Rename the normals
%     first_blocks = cell(0, 1);
%     second_blocks = cell(0, 1);
%     count = 1;
%     for a = 1:length(blocks)
%         for b = a + 1:length(blocks)
%             if sum(ismember(blocks{a}, blocks{b})) ~= 2, continue; end
%             
%             if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n1) > 0.5 || dot(tangent_gradients{a}.n1, tangent_gradients{b}.n2) > 0.5
%                  first_blocks{count}.n = tangent_gradients{a}.n1;
%                  first_blocks{count + 1}.n = tangent_gradients{a}.n2;
%                  for var = 1:length(tangent_gradients{a}.gradients)
%                     first_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn1;                   
%                     first_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;  
%                     first_blocks{count + 1}.dn{var} = tangent_gradients{a}.gradients{var}.dn2;                   
%                     first_blocks{count + 1}.index{var} = tangent_gradients{a}.gradients{var}.index;
%                 end
%             end
%             
%             if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n1) > 0.5             
%                 second_blocks{count}.n = tangent_gradients{b}.n1;
%                 second_blocks{count + 1}.n = tangent_gradients{b}.n2;
%                 for var = 1:length(tangent_gradients{b}.gradients)                   
%                     second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;                   
%                     second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
%                     second_blocks{count + 1}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;                    
%                     second_blocks{count + 1}.index{var} = tangent_gradients{b}.gradients{var}.index;
%                 end 
%                 count = count + 2;
%             end
%             if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n2) > 0.5                    
%                 second_blocks{count}.n = tangent_gradients{b}.n2;
%                 second_blocks{count + 1}.n = tangent_gradients{b}.n1;
%                 for var = 1:length(tangent_gradients{b}.gradients)                    
%                     second_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;                   
%                     second_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
%                     second_blocks{count + 1}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;                   
%                     second_blocks{count + 1}.index{var} = tangent_gradients{b}.gradients{var}.index;
%                 end
%                 count = count + 2;
%             end
%             %if count > 1
%             %    if iter == 1 || iter == num_iters
%             %        ia = blocks{a}(~ismember(blocks{a}, blocks{b}));
%             %        ib = blocks{b}(~ismember(blocks{b}, blocks{a}));
%             %        myvector(centers{ia}, first_blocks{count - 1}.n, 1, 'r');
%             %        myvector(centers{ib},second_blocks{count - 1}.n, 1, 'r');
%             %        myvector(centers{ia}, first_blocks{count - 2}.n, 1, 'b');
%             %        myvector(centers{ib},second_blocks{count - 2}.n, 1, 'b');
%             %    end
%             %end
%         end
%     end
%         
%     %% Compute gradients    
%     F = zeros(D * length(first_blocks), 1);
%     Jc = zeros(D * length(first_blocks), length(centers) * D);
%     Jr = zeros(D * length(first_blocks), length(centers));
%     
%     for i = 1:length(first_blocks)
%         n = first_blocks{i}.n;
%         m = second_blocks{i}.n; 
%         
%         for var = 1:length(first_blocks{i}.dn)
%             index = first_blocks{i}.index{var};
%             dn = first_blocks{i}.dn{var};
%             dm = zeros(size(dn));
%             [f, df] = difference_derivative(n, dn, m, dm);
%             if numel(df) == D * D
%                 Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
%             else
%                 Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
%             end
%         end
%         for var = 1:length(second_blocks{i}.dn)
%             index = second_blocks{i}.index{var};
%             dm = second_blocks{i}.dn{var};
%             dn = zeros(size(dm));
%             [f, df] = difference_derivative(n, dn, m, dm);
%             if numel(df) == D * D
%                 Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
%             else
%                 Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
%             end
%         end
%         F(D * i - D + 1:D * i) = f;
%     end

    [F, Jc, Jr] = compute_energy3(centers, radii, blocks);

    J = [Jc, Jr];
    
    disp(F' * F);
    history(iter) = F' * F;
    num_centers = length(centers);
    num_poses = 1;
    %damping = 0.0001; % one block
    damping = 10; % whole model
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    LHS = damping * I + J' * J;
    rhs = J' * F;
    delta = -  LHS \ rhs;
    poses{1}.centers = centers;
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    centers = poses{1}.centers;
    
end
figure; hold on; plot(1:num_iters, history, 'lineWidth', 2);