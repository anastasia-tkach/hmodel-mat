function [pose] = compute_energy1(pose, radii, blocks, settings, display)

D = settings.D;

if settings.energy1 == false
    return
end

num_points = pose.num_points;
indices = pose.indices;
points = pose.points;
centers = pose.centers;

f = zeros(num_points, 1);
Jc = zeros(num_points, length(centers) * D);
Jr = zeros(num_points, length(centers));

%% Compute tangent points
[tangent_gradients] = blocks_tangent_points_gradients(centers, blocks, radii, D);
for i = 1:num_points
    
    if isempty(indices{i}), continue; end
    
    %% Determine current block
    if length(indices{i}) == 3
        for b = 1:length(blocks)
            if (length(blocks{b}) < 3), continue; end
            abs_index = [abs(indices{i}(1)), abs(indices{i}(2)), abs(indices{i}(3))];
            indicator = ismember(blocks{b}, abs_index);
            if sum(indicator) == 3
                tangent_gradient = tangent_gradients{b};
                break;
            end
        end
    end
    
    %% Case 1
    if length(indices{i}) == 1
        [f_i, Jc_i, Jr_i] = energy1_case1(points{i}, centers{indices{i}(1)}, radii{indices{i}(1)});
        f(i) = f_i;
        Jc(i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = Jc_i;
        Jr(i, indices{i}(1)) = Jr_i;
    end
    
    %% Case 2
    if length(indices{i}) == 2
        [f_i, Jc1_i, Jr1_i, Jc2_i, Jr2_i] = energy1_case2_numerical(points{i}, centers{indices{i}(1)}, centers{indices{i}(2)}, radii{indices{i}(1)}, radii{indices{i}(2)});
        
        f(i) = f_i;
        Jc(i, D * indices{i}(1) - D + 1:D * indices{i}(1)) = Jc1_i;
        Jc(i, D * indices{i}(2) - D + 1:D * indices{i}(2)) = Jc2_i;
        Jr(i, indices{i}(1)) = Jr1_i;
        Jr(i, indices{i}(2)) = Jr2_i;
    end
    %% Case 3
    if length(indices{i}) == 3
        v1 = tangent_gradient.v1; v2 = tangent_gradient.v2; v3 = tangent_gradient.v3;
        u1 = tangent_gradient.u1; u2 = tangent_gradient.u2; u3 = tangent_gradient.u3;
        Jv1 = tangent_gradient.Jv1; Jv2 = tangent_gradient.Jv2; Jv3 = tangent_gradient.Jv3;
        Ju1 = tangent_gradient.Ju1; Ju2 = tangent_gradient.Ju2; Ju3 = tangent_gradient.Ju3;
        if (indices{i}(1) > 0)
            [f_i, Jc1_i, Jr1_i, Jc2_i, Jr2_i, Jc3_i, Jr3_i] = energy1_case3_numerical(points{i}, v1, v2, v3, Jv1, Jv2, Jv3, D);
        else
            [f_i, Jc1_i, Jr1_i, Jc2_i, Jr2_i, Jc3_i, Jr3_i] = energy1_case3_numerical(points{i}, u1, u2, u3, Ju1, Ju2, Ju3, D);
        end
        
        f(i) = f_i;
        Jc(i, D * abs(indices{i}(1)) - D + 1:D * abs(indices{i}(1))) = Jc1_i;
        Jc(i, D * abs(indices{i}(2)) - D + 1:D * abs(indices{i}(2))) = Jc2_i;
        Jc(i, D * abs(indices{i}(3)) - D + 1:D * abs(indices{i}(3))) = Jc3_i;
        Jr(i, abs(indices{i}(1))) = Jr1_i;
        Jr(i, abs(indices{i}(2))) = Jr2_i;
        Jr(i, abs(indices{i}(3))) = Jr3_i;
    end
    
end

pose.f1 = f;
pose.Jc1 = Jc;
pose.Jr1 = Jr;

if (display)
    if D == 3
        display_result_convtriangles(pose, blocks, radii, false); mypoints(pose.points, 'm'); drawnow;
        set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    else
        display_result_2D(pose, blocks, radii, true); drawnow;
       set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    end
end
