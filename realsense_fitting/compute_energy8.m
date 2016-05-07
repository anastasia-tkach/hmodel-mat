function [pose] = compute_energy8(pose, blocks)

D = 3;
centers = pose.centers;
initial_centers = pose.initial_centers;

F = zeros(16, 1);
Jc = zeros(16, D * length(centers));
Jr = zeros(16, length(centers));
count = 1;

for b = 1:length(blocks)
    if b > 15 && b ~= 28, continue; end
    
    i = blocks{b}(1);
    j = blocks{b}(2);
    
    ci = centers{i};
    cj = centers{j};
    
    c0i = initial_centers{i};
    c0j = initial_centers{j};
    
    f = (ci - cj)' * (ci - cj) - (c0i - c0j)' * (c0i - c0j);
    
    j_ci = 2 *  ci' - 2 * cj';
    j_cj = 2 *  cj' - 2 * ci';
    
    F(count) = f;
    
    Jc(count, D * (i - 1) + 1 : D * i) = j_ci;
    Jc(count, D * (j - 1) + 1 : D * j) = j_cj;
    
    count = count + 1;    
end

pose.f8 = F;
pose.Jc8 = Jc;
pose.Jr8 = Jr;

%{
centers = pose.centers;
real_phalanges_length = settings.real_phalanges_length;
names_map = settings.names_map;

finger_indices = cell(5, 1);
% Thumb
finger_indices{1}.start = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_middle')];
finger_indices{1}.end = [names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_top'), names_map('thumb_additional')];
% Index
finger_indices{2}.start = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle')];
finger_indices{2}.end = [names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
% Middle
finger_indices{3}.start = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle')];
finger_indices{3}.end = [names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
% Ring
finger_indices{4}.start = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle')];
finger_indices{4}.end = [names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
% Pinky
finger_indices{5}.start = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle')];
finger_indices{5}.end = [names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];

F = zeros(16, 1);
Jc = zeros(16, D * length(centers));
Jr = zeros(16, length(centers));
count = 1;

for u = 1:length(finger_indices)
    for v = 1:length(finger_indices{u}.start)
        i = finger_indices{u}.start(v);
        j = finger_indices{u}.end(v);
        
        ci = centers{i};
        cj = centers{j};
        
        f = (ci - cj)' * (ci - cj) - real_phalanges_length{u}(v)^2;
        
        j_ci = 2 *  ci' - 2 * cj';
        j_cj = 2 *  cj' - 2 * ci';
        
        F(count) = f;
               
        Jc(count, D * (i - 1) + 1 : D * i) = j_ci;
        Jc(count, D * (j - 1) + 1 : D * j) = j_cj;
        
        count = count + 1;
        
    end
end

pose.f8 = F;
pose.Jc8 = Jc;
pose.Jr8 = Jr;
%}