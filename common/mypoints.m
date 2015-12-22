function mypoints(points, color)

if isempty(points), return; end
D = 1;
for i = 1:length(points)
    if ~isempty(points{i})
        D = length(points{i});
        break;
    end
end

if D == 3
    P = zeros(length(points), 3);
    k = 0;
    for i = 1:length(points)
        if ~isempty(points{i})
            k = k + 1;
            P(k, :) = points{i}';
        end
    end
    P = P(1:k, :);
    scatter3(P(:, 1), P(:, 2), P(:, 3), 15, color, 'o', 'filled');
end
if D == 2
    P = zeros(length(points), 2);
    k = 0;
    for i = 1:length(points)
        if ~isempty(points{i})
            k = k + 1;
            P(i, :) = points{i}';
        end
    end
    P = P(1:k, :);
    scatter(P(:, 1), P(:, 2), 25, color, 'o', 'filled');
end