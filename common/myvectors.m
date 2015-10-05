function [] = myvectors(origins, vectors, factor, color)

if isempty(origins) || isempty(vectors), return; end

if length(origins{1}) == 3
    P = zeros(length(origins), 3);
    Q = zeros(length(origins), 3);
    L = zeros(length(origins) * 3, 3);
    k = 0;
    for i = 1:length(origins)
        if ~isempty(origins{i}) && ~isempty(vectors{i})
            k = k + 1;
            P(k, :) =  origins{i}';
            Q(k, :) =  origins{i}' + factor * vectors{i}';
            L(3 * (k - 1) + 1, :) = origins{i}';
            L(3 * (k - 1) + 2, :) =  origins{i}' +  factor *vectors{i}';
            L(3 * (k - 1) + 3, :) = [NaN, NaN, NaN];
        end
    end
    if (k > 0)
        L = L(1:3*k, :);
        line(L(1:3*k, 1), L(1:3*k, 2), L(1:3*k, 3), 'lineWidth', 2, 'color', color);
    end
end

if length(origins{1}) == 2
    P = zeros(length(origins), 2);
    Q = zeros(length(origins), 2);
    L = zeros(length(origins) * 3, 2);
    k = 0;
    for i = 1:length(origins)
        if ~isempty(origins{i}) && ~isempty(vectors{i})
            k = k + 1;
            P(k, :) =  origins{i}';
            Q(k, :) =  origins{i}' +  factor *vectors{i}';
            L(3 * (k - 1) + 1, :) = origins{i}';
            L(3 * (k - 1) + 2, :) = origins{i}' + factor *vectors{i}';
            L(3 * (k - 1) + 3, :) = [NaN, NaN];
        end
    end
    if (k > 0)
        L = L(1:3*k, :);
        line(L(1:3*k, 1), L(1:3*k, 2), 'lineWidth', 2, 'color', color);
    end
end