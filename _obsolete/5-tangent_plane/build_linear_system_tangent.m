function [pose] = build_linear_system_tangent(pose, radii, D)

num_points = pose.num_points;
num_centers = pose.num_centers; 
I = pose.I;
points = pose.points;
centers = pose.centers;

f = zeros(num_points, 1);
Jc = zeros(num_points, num_centers * D);
Jr = zeros(num_points, num_centers);

for i = 1:num_points
    
    %% Case 1
    if length(I{i}) == 1
        [f_i, Jc_i, Jr_i] = energy1_case1(points{i}, centers{I{i}(1)}, radii{I{i}(1)});
        f(i) = f_i;
        Jc(i, D * I{i}(1) - D + 1:D * I{i}(1)) = Jc_i;
        Jr(i, I{i}(1)) = Jr_i;
    end
    
    %% Case 2
    if length(I{i}) == 2
        [f_i, Jc1_i, Jr1_i, Jc2_i, Jr2_i] = energy1_case2_numerical(points{i}, centers{I{i}(1)}, centers{I{i}(2)}, radii{I{i}(1)}, radii{I{i}(2)});
        f(i) = f_i;
        Jc(i, D * I{i}(1) - D + 1:D * I{i}(1)) = Jc1_i;
        Jc(i, D * I{i}(2) - D + 1:D * I{i}(2)) = Jc2_i;
        Jr(i, I{i}(1)) = Jr1_i;
        Jr(i, I{i}(2)) = Jr2_i;
    end       
    
end

pose.f = f;
pose.Jc = Jc;
pose.Jr = Jr;
