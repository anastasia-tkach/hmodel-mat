function [poses, radii, blocks] = parse_argument(X, poses, radii, blocks)


D = 3;

num_poses = length(poses);
num_centers = length(poses{1}.centers);

for p = 1:num_poses
    c = X(D * num_centers * (p - 1) + 1:D * num_centers * p);
    for o = 1:num_centers
        poses{p}.centers{o} = c(D * o - D + 1:D * o);
    end
end
for o = 1:num_centers
    radii{o} = X(D * num_poses * num_centers + o);
end
[blocks] = reindex(radii, blocks);

