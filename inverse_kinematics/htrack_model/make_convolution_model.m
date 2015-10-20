function [centers, radii, blocks, solid_blocks] = make_convolution_model(segments, mode)

blocks = {0, 1};
centers = cell(0, 1);
radii = cell(0, 1);

if strcmp(mode, 'finger')
    for i = 1:length(segments)
        V = transform(segments{i}.V, segments{i}.global);
        centers{i} = V(:, end - 1);
        radii{i} = segments{i}.radius1 + randn/1000;  
    end   
    centers{4} =  V(:, end);
    radii{4} = segments{3}.radius2 + randn/1000;  
    blocks = {[1, 2]; [2, 3]; [3, 4]};
    blocks = reindex(radii, blocks);
    solid_blocks = {[1], [2], [3]};
    return
end

for i = 1:length(segments)
    V = transform(segments{i}.V, segments{i}.global);
    centers{2 + 2 * (i - 1) + 1} = V(:, end - 1);
    centers{2 + 2 * i} = V(:, end);
    radii{2 + 2 * (i - 1) + 1} = segments{i}.radius1 + randn/1000;
    radii{2 + 2 * i} = segments{i}.radius2 + randn/1000;
    blocks{1 + i} = [2 + 2 * (i - 1) + 1, 2 + 2 * i];
end
radii{1} = 0.3 * radii{3} + randn/1000; radii{2} = 0.3 * radii{4} + randn/1000;
radii{3} = 0.3 * radii{3} + randn/1000; radii{4} = 0.3 * radii{4} + randn/1000;
centers{1} = centers{3} - 25 * [1; 0; 0];
centers{2} = centers{4} - 25 * [1; 0; 0];
centers{3} = centers{3} + 25 * [1; 0; 0];
centers{4} = centers{4} + 25 * [1; 0; 0];
blocks{1} = [1, 2, 3]; blocks{2} = [2, 3, 4];

J = [16, 14, 12, 11, 22, 20, 18, 17, 28, 26, 24, 23, 34, 32, 30, 29, 10, 8, 6, 5, 4, 2, 3, 1];
new_centers = {}; new_radii = {};
for i = 1:length(J)
    new_centers{i} = centers{J(i)};
    new_radii{i} = radii{J(i)};
end
blocks = {[1, 2], [2, 3], [3, 4], [5, 6], [6, 7], [7, 8], [9, 10], [10, 11], [11, 12]...
    [13, 14], [14, 15], [15, 16], [17, 18], [18, 19], [19, 20], [21, 22, 23], [22, 23, 24], [20, 23], [4, 22], [8, 21], [12, 22], [16, 21]};

centers = new_centers; radii = new_radii;
blocks = reindex(radii, blocks);

solid_blocks = {[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16, 17], [18], [19], [20], [21], [22]};

