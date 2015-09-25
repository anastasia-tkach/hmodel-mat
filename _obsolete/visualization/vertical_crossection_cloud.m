function [] = vertical_crossection_cloud(points, p0)

max_x = 0;
min_x = Inf;
max_y = 0;
min_y = Inf;
max_z = 0;
min_z = Inf;
for i = 1:length(points)
    if (points{i}(1) > max_x), max_x = points{i}(1); end;
    if (points{i}(2) > max_y), max_y = points{i}(2); end;
    if (points{i}(3) > max_z), max_z = points{i}(3); end;
    if (points{i}(1) < min_x), min_x = points{i}(1); end;
    if (points{i}(2) < min_y), min_y = points{i}(2); end;
    if (points{i}(3) < min_z), min_z = points{i}(3); end;
end

distance = norm([max_x; max_y; max_z] - [min_x; min_y; min_z]);
threshold = distance / 2;

n = [1; 0; 0];

k = 1;
%figure; hold on;
projections = [];
for i = 1:length(points)
    p = points{i};
    d = (p - p0)' * n;
    if d < threshold
        projections = [projections; (p - n * d)'];
        %scatter3(p0(1), p0(2), p0(3), 30, 'filled', 'm');
        %scatter3(p(1), p(2), p(3), 30, 'filled', 'b');
        %scatter3(projections{k}(1), projections{k}(2), projections{k}(3), 30, 'filled', 'g');
        %line([p0(1) p0(1) + n(1)], [p0(2) p0(2) + n(2)], [p0(3) p0(3) + n(3)], 'color', 'm');
        %line([p(1) p0(1)], [p(2) p0(2)], [p(3) p0(3)], 'color', 'b');
        %line([p(1) projections{k}(1)], [p(2) projections{k}(2)], [p(3) projections{k}(3)], 'color', 'g');
        k = k + 1;
    end
end

figure; hold on;
scatter(projections(:, 3), projections(:, 2), 30, 'filled', 'b');
xlim([0, 1]); ylim([0, 1]);
axis equal;

