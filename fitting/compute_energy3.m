function [F, Jc, Jr] = compute_energy3(centers, radii, smooth_blocks, settings)

disp('loading fist skip blocks');
load('_my_hand/semantics/fist_skip_blocks_indices');

D = length(centers{1});

tangent_gradients = cell(length(smooth_blocks), 1);
for i = 1:length(smooth_blocks)
    
    if settings.p == 5 && ismember(i, fist_skip_blocks_indices), continue; end
    
    if length(smooth_blocks{i}) == 3
        c1 = centers{smooth_blocks{i}(1)}; c2 = centers{smooth_blocks{i}(2)}; c3 = centers{smooth_blocks{i}(3)};
        r1 = radii{smooth_blocks{i}(1)}; r2 = radii{smooth_blocks{i}(2)}; r3 = radii{smooth_blocks{i}(3)};
        
        gradients = get_parameters_gradients(smooth_blocks{i}, cell(length(centers)), D, 'fitting');
        
        [~, ~, ~, ~, ~, ~, n1, n2, gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, gradients);
        tangent_gradients{i}.gradients = gradients;
        tangent_gradients{i}.n1 = n1; tangent_gradients{i}.n2 = n2;
    end
end

%% Rename the normals
discard_threshold = 0.7;

first_smooth_blocks = cell(0, 1);
second_smooth_blocks = cell(0, 1);
count = 1;
for a = 1:length(smooth_blocks)
    
    for b = a + 1:length(smooth_blocks)
        
        if settings.p == 5 && (ismember(a, fist_skip_blocks_indices) || ismember(b, fist_skip_blocks_indices)), continue; end
        
        if sum(ismember(smooth_blocks{a}, smooth_blocks{b})) ~= 2, continue; end
        
        if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n1) < discard_threshold && ...
            dot(tangent_gradients{a}.n1, tangent_gradients{b}.n2) < discard_threshold, continue; end
        
        first_smooth_blocks{count}.n = tangent_gradients{a}.n1;
        first_smooth_blocks{count + 1}.n = tangent_gradients{a}.n2;
        for var = 1:length(tangent_gradients{a}.gradients)
            first_smooth_blocks{count}.dn{var} = tangent_gradients{a}.gradients{var}.dn1;
            first_smooth_blocks{count}.index{var} = tangent_gradients{a}.gradients{var}.index;
            first_smooth_blocks{count + 1}.dn{var} = tangent_gradients{a}.gradients{var}.dn2;
            first_smooth_blocks{count + 1}.index{var} = tangent_gradients{a}.gradients{var}.index;
        end        
        
        if dot(tangent_gradients{a}.n1, tangent_gradients{b}.n1) > discard_threshold
            second_smooth_blocks{count}.n = tangent_gradients{b}.n1;
            second_smooth_blocks{count + 1}.n = tangent_gradients{b}.n2;
            for var = 1:length(tangent_gradients{b}.gradients)
                second_smooth_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;
                second_smooth_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                second_smooth_blocks{count + 1}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;
                second_smooth_blocks{count + 1}.index{var} = tangent_gradients{b}.gradients{var}.index;
            end
            count = count + 2;
        elseif dot(tangent_gradients{a}.n1, tangent_gradients{b}.n2) > discard_threshold
            second_smooth_blocks{count}.n = tangent_gradients{b}.n2;
            second_smooth_blocks{count + 1}.n = tangent_gradients{b}.n1;
            for var = 1:length(tangent_gradients{b}.gradients)
                second_smooth_blocks{count}.dn{var} = tangent_gradients{b}.gradients{var}.dn2;
                second_smooth_blocks{count}.index{var} = tangent_gradients{b}.gradients{var}.index;
                second_smooth_blocks{count + 1}.dn{var} = tangent_gradients{b}.gradients{var}.dn1;
                second_smooth_blocks{count + 1}.index{var} = tangent_gradients{b}.gradients{var}.index;
            end
            count = count + 2;
        end
        %if count > 1
        %    if iter == 1 || iter == num_iters
        %        ia = smooth_blocks{a}(~ismember(smooth_blocks{a}, smooth_blocks{b}));
        %        ib = smooth_blocks{b}(~ismember(smooth_blocks{b}, smooth_blocks{a}));
        %        myvector(centers{ia}, first_smooth_blocks{count - 1}.n, 1, 'r');
        %        myvector(centers{ib},second_smooth_blocks{count - 1}.n, 1, 'r');
        %        myvector(centers{ia}, first_smooth_blocks{count - 2}.n, 1, 'b');
        %        myvector(centers{ib},second_smooth_blocks{count - 2}.n, 1, 'b');
        %    end
        %end
    end
end

%% Compute gradients
F = zeros(D * length(first_smooth_blocks), 1);
Jc = zeros(D * length(first_smooth_blocks), length(centers) * D);
Jr = zeros(D * length(first_smooth_blocks), length(centers));

for i = 1:length(first_smooth_blocks)
    n = first_smooth_blocks{i}.n;
    m = second_smooth_blocks{i}.n;
    
    for var = 1:length(first_smooth_blocks{i}.dn)
        index = first_smooth_blocks{i}.index{var};
        dn = first_smooth_blocks{i}.dn{var};
        dm = zeros(size(dn));
        [f, df] = difference_derivative(n, dn, m, dm);
        if numel(df) == D * D
            Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
        else
            Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
        end
    end
    for var = 1:length(second_smooth_blocks{i}.dn)
        index = second_smooth_blocks{i}.index{var};
        dm = second_smooth_blocks{i}.dn{var};
        dn = zeros(size(dm));
        [f, df] = difference_derivative(n, dn, m, dm);
        if numel(df) == D * D
            Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) = Jc(D * i - D + 1:D * i, D * index - D + 1:D * index) + df;
        else
            Jr(D * i - D + 1:D * i, index) = Jr(D * i - D + 1:D * i, index) + df;
        end
    end
    F(D * i - D + 1:D * i) = f;
end