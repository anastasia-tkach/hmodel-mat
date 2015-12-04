function [F, palm_center] = compute_principle_axis(points, verbose)
D = length(points{1});

P = zeros(length(points), D);
for i = 1:length(points)
    P(i, :) = points{i}';
end
n = size(P, 1);
palm_center = mean(P)';
data = P - repmat(palm_center', n, 1);
Covariance = 1/n * (data' * data);
[U, S, ~] = svd(Covariance);
s = diag(S) .^ (1/2);

u1 = s(1) * U(:, 1); u2 = s(2) * U(:, 2); u3 = s(3) * U(:, 3);
r1 = 2 * s(1); r2 = 2 * s(2);

C = ones(4, 1);
V = [-r1, -r2, 0; r1, -r2, 0; r1, r2, 0; -r1, r2, 0];
V = V * inv(U);
V(:, 1) = V(:, 1); V(:, 2) = V(:, 2); V(:, 3) = V(:, 3);

%% Set up return values
F = [u1 / norm(u1), u2 / norm(u2), u3 / norm(u3)];

%% Display fitted plane

if verbose
    scatter3(data(:, 1) + palm_center(1), data(:, 2) + palm_center(2), data(:, 3) + palm_center(3), 25, 'filled', 'markerFaceColor', [0.5, 0.65, 0.8]);
    %hold on; h = fill3(V(:, 1) + palm_center(1), V(:, 2) + palm_center(2), V(:, 3) + palm_center(3), C, 'EdgeColor', 'none', 'FaceColor', [205/255, 185/255, 195/255], 'FaceAlpha', 0.5);    
    myline(palm_center, palm_center + 2 * u1,  [0.9, 0.4, 0.7]);
    myline(palm_center, palm_center + 2 * u2,  [0.2, 0.2, 1]);
    u3 = u3 / norm(u3) * max(norm(u3), 2);
    myline(palm_center, palm_center + 2 * u3,  [0.6, 0.2, 1]);

end


