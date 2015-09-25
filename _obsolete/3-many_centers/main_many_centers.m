close all; clc; clear;
load P1;
load R;
load C1;

close all;
colors = {[1, 0.3, 0.5], [1, 0.8, 0], [1, 0.5, 0.2]};


%% Compute gradient
num_points = size(P, 1);
num_centers = size(C, 1);

centers = cell(num_centers, 1);
radii = cell(num_centers, 1);
children = cell(num_centers, 1);
points = cell(num_points, 1);

for i = 1:num_centers
    centers{i} = C(i, :)';
    radii{i} = R(i);
end
for i = 1:num_centers - 1
    children{i} = [i + 1];
end
for i = 1:num_points
    points{i} = P(i, :)';
end

f = zeros(num_points, 1);
J = zeros(num_points, num_centers * 3);
alpha = 0;



%% Compute correspondences

for iter = 1:10
    
    I = cell(num_points, 1);
    min_distance = Inf * ones(num_points, 1);
    projections = cell(num_points, 1);
    index = cell(1, 1);
    
    f = zeros(num_points, 1);
    J = zeros(num_points, num_centers * 3);
    
    for i = 1:num_points
        
        for j = 1:num_centers
            
            for k = 1:length(children{j})
                
                u = centers{children{j}(k)} - centers{j};
                v = points{i} - centers{j};
                projection = u' * v / (u' * u);
                if projection <= 0,
                    index = [j];
                    t = centers{j};
                end
                if projection > 0 && projection <= 1
                    index = [j, children{j}(k)];
                    t = centers{j} + projection * (centers{children{j}(k)} - centers{j});
                end
                if projection > 1
                    index = [children{j}(k)];
                    t = centers{children{j}(k)};
                end
                
            end
            
            if norm(points{i} - t) < min_distance(i)
                min_distance(i) = norm(points{i} - t);
                I{i} = index;
                projections{i} = t;
            end
            
        end
    end
    
    %% Display
    display_many_centers(P, centers, radii)
    for i = 1:num_points
        scatter(points{i}(1), points{i}(2), 30, [1, 0.5, 0.2], 'filled');
        line([projections{i}(1) points{i}(1)], [projections{i}(2) points{i}(2)], 'lineWidth', 2, 'color', [1, 0.8, 0]);
    end
    
    %% Update circles    
    
    for i = 1:num_points
        %% Case 1
        if length(I{i}) == 1
            [fi, Ji] = case1(points{i}, centers{I{i}(1)}, radii{I{i}(1)});
            f(i) = fi;
            J(i, 3 * I{i}(1) - 2:3 * I{i}(1)) = Ji;
            c = centers{I{i}(1)};
            r = radii{I{i}(1)};
        end
        
        %% Case 2
        if length(I{i}) == 2
            [fi, J1i, J2i, c, r] = case2_many_centers(points{i}, centers{I{i}(1)}, centers{I{i}(2)}, radii{I{i}(1)}, radii{I{i}(2)});
            f(i) = fi;
            J(i, 3 * I{i}(1) - 2:3 * I{i}(1)) = J1i;
            J(i, 3 * I{i}(2) - 2:3 * I{i}(2)) = J2i;
        end   
        
        q = points{i} - (norm(points{i} - c) - r) * (points{i} - c) / norm(points{i} - c);
        scatter(q(1), q(2), 30, [1, 0.5, 0.2], 'filled');
        line([q(1), points{i}(1)], [q(2), points{i}(2)], 'lineWidth', 2, 'color', [1, 0.5, 0.2]);
        
    end
    
    disp(norm(f))
    delta = - (J' * J) \ (J' * f);
    
    for o = 1:num_centers
        centers{o} = centers{o} + delta(3 * o - 2:3 * o - 1);
        radii{o} = radii{o} + delta(3 * o);   
    end
    
end






