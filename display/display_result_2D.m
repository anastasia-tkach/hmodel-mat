function [] = display_result_2D(centers, points, blocks, radii, display_data)
D = 2;
%% Generating the volumetric domain data:
n = 40; 

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
[x, y] = meshgrid(xm,ym);
N = numel(x);
P = [reshape(x, N, 1), reshape(y, N, 1)];
figure; hold on;
%figure('units','normalized','outerposition',[0 0 1 1]); hold on;
set(gcf,'color','w');

composition = Inf * ones(N, 1);
for i = 1:length(blocks)
    c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)};
    r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
    distances = distance_to_model_convsegment(c1, c2, r1, r2, P');
    composition = min(distances, composition);
end

composition = reshape(composition, size(x));
colormap([0.45 0.9 1; 1, 1, 1]); caxis([-1 1]);
contourf(x, y, composition, 1000, 'edgeColor', 'none');
grid off; axis equal; axis off;

%% Display data
if (display_data)
    skip = 1;
    if isfield(pose, 'indices');
        k = 0;
        P = zeros(length(points), D);
        Q = zeros(length(points), D);
        L = zeros(length(points)*3, D);
        for i = 1:skip:length(points)
            if ~isempty(indices{i})
                k = k + 1;
                P(k, :) =  points{i}';
                Q(k, :) = projections{i}';
                L(3 * (k - 1) + 1, :) = points{i}';
                L(3 * (k - 1) + 2, :) = projections{i}';
                L(3 * (k - 1) + 3, :) = [NaN, NaN];
            end
        end
        if (k > 0)
            P = P(1:k, :); Q = Q(1:k, :); L = L(1:3*k, :);
            %scatter(Q(:, 1), Q(:, 2), 10, [0.1, 0.8, 0.8], 'filled', 'o');
            scatter(P(:, 1), P(:, 2), 10, 'filled', 'o', 'm');
            line(L(:, 1), L(:, 2), 'lineWidth', 2, 'color', [0.1, 0.8, 0.8]);
        end
    else
        k = 0;
        P = zeros(length(points), D);
        for i = 1:skip:length(points)
            k = k + 1;
            P(k, :) =  points{i}';
        end
        P = P(1:k, :);
        scatter(P(:, 1), P(:, 2), 10, 'filled', 'o', 'm');
    end
end

