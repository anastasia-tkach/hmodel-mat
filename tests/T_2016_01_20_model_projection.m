close all;
clear;

input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
mode = 'my_hand';

load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
invalid_blocks = [];

%% Display
segment_color = [0.3, 0.5, 1];
triangle_color =  [0.6, 0.4, 0.8];
width = 2;

axis_indices = [1, 2];

figure; hold on; axis equal; axis off;

%% Draw circles
for i = 1:length(centers)
    draw_circle(centers{i}(axis_indices), radii{i}, 'b');    
end

%% Draw tangents
for i = 1:length(blocks)
    if ismember(i, invalid_blocks)
        for j = 1:length(blocks{i}), draw_circle(centers{blocks{i}(j)}(axis_indices), radii{blocks{i}(j)}, [1, 0, 0.5]); end
        indices = nchoosek(blocks{i}, 2); index1 = indices(:, 1); index2 = indices(:, 2);
        for j = 1:length(index1), myline(centers{index1(j)}, centers{index2(j)}, [1, 0, 0.5]); end
    else
        if length(blocks{i}) == 2
            c1 = centers{blocks{i}(1)}(axis_indices); c2 = centers{blocks{i}(2)}(axis_indices);
            r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
            if norm(c1 - c2) < r1 - r2, continue; end
            [lt1, lt2, rt1, rt2] = get_tangents(c1, c2, r1, r2);
            line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', 2, 'color',  segment_color);
            line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', 2, 'color',  segment_color);
        end
        if length(blocks{i}) == 3
            c1 = centers{blocks{i}(1)}(axis_indices); c2 = centers{blocks{i}(2)}(axis_indices); c3 = centers{blocks{i}(3)}(axis_indices);
            r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
            if norm(c1 - c2) < r1 - r2, continue; end
            if norm(c1 - c3) < r1 - r3, continue; end
            if norm(c2 - c3) < r2 - r3, continue; end
            
            [lt1, lt2, rt1, rt2] = get_tangents(c1, c2, r1, r2);
            d1 = point_to_segment(c3, lt1, lt2); d2 = point_to_segment(c3, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', width, 'color',  triangle_color);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', width, 'color',  triangle_color); end
            
            [lt1, lt2, rt1, rt2] = get_tangents(c1, c3, r1, r3);
            d1 = point_to_segment(c2, lt1, lt2); d2 = point_to_segment(c2, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', width, 'color', triangle_color);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', width, 'color',  triangle_color); end
            
            [lt1, lt2, rt1, rt2] = get_tangents(c2, c3, r2, r3);
            d1 = point_to_segment(c1, lt1, lt2); d2 = point_to_segment(c1, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', width, 'color', triangle_color);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', width, 'color',  triangle_color); end
        end
    end
end
