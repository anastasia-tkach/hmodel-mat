function [centers, points] = rotate_model(centers, points, R)

for o = 1:length(centers)
    centers{o} = R * centers{o};
end
for o = 1:length(points)
    points{o} = R * points{o};
end
