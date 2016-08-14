function [E_rastorized, E_continuous, closest_model_points] = compute_rastorized_E3D_metric(data_points, rastorized_model_points, continuous_model_points)

%% Compute continious metric
E_continuous = 0;
if ~isempty(continuous_model_points)
    for i = 1:length(data_points)
        if rem(i, 1000) == 0, disp(i); end
        p = data_points{i};
        q = continuous_model_points{i};
        d = norm(p - q);
        w = 1/sqrt(d + 1e-3);
        weight = 1;
        if d > 1e-3
            weight = w * 3.5;
        end
        E_continuous = E_continuous + weight * norm(p - q);
    end
    E_continuous = E_continuous / length(data_points);
end

%% Make kd-tree
X = zeros(length(rastorized_model_points), 3);
for i = 1:length(rastorized_model_points)
    X(i, :) = rastorized_model_points{i}';
end
kd_tree = KDTreeSearcher(X);

%% Compute rastorized metric
closest_model_points = cell(length(data_points), 1);
E_rastorized = 0;

for i = 1:length(data_points)
    if rem(i, 1000) == 0, disp(i); end
    p = data_points{i};
    
    index = knnsearch(kd_tree, p', 'K', 1);
    q = rastorized_model_points{index};
    min_distance = norm(p - q);
    closest_model_points{i} = q;
    
    %{
    %% Find closest point
    min_distance = Inf;
    min_index = -1; 
    for j = 1:length(rastorized_model_points)
        q = rastorized_model_points{j};
        d = norm(p - q);
        if (d < min_distance)
            min_distance = d;
            closest_model_points{i} = q;
            min_index = j;
        end
    end
    %}
    
    %% Compute metric
    d = min_distance;
    w = 1/sqrt(d + 1e-3);
    weight = 1;
    if d > 1e-3
        weight = w * 3.5;
    end
    E_rastorized = E_rastorized +  weight * d;
end

E_rastorized = E_rastorized / length(data_points);


