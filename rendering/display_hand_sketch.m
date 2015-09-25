function [] = display_hand_sketch(poses, radii, blocks)

axis_indices = [1, 2];
blocks = blocks(1:25);
for p = 1:length(poses)
    figure; hold on; axis equal; axis off;    
    
    points_2D = cell(length(poses{p}.points), 1);
    for i = 1:length(poses{p}.points)
        points_2D{i} = poses{p}.points{i}(axis_indices);
    end
    mypoints(points_2D, [0.8, 0.6, 0.8]);
    for i = 1:length(blocks)
        if length(blocks{i}) == 2
            [lt1, lt2, rt1, rt2] = get_tangents(poses{p}.centers{blocks{i}(1)}(axis_indices), poses{p}.centers{blocks{i}(2)}(axis_indices), ...
                radii{blocks{i}(1)}, radii{blocks{i}(2)});
            line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', 2, 'color',  [0.3, 0.5, 1]);
            line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', 2, 'color',  [0.3, 0.5, 1]);
        end
        if length(blocks{i}) == 3
            c1 = poses{p}.centers{blocks{i}(1)}(axis_indices); c2 = poses{p}.centers{blocks{i}(2)}(axis_indices); c3 = poses{p}.centers{blocks{i}(3)}(axis_indices);
            r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
            
            [lt1, lt2, rt1, rt2] = get_tangents(c1, c2, r1, r2);
            d1 = point_to_segment(c3, lt1, lt2); d2 = point_to_segment(c3, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]); end
            
            [lt1, lt2, rt1, rt2] = get_tangents(c1, c3, r1, r3);
            d1 = point_to_segment(c2, lt1, lt2); d2 = point_to_segment(c2, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]); end
            
            [lt1, lt2, rt1, rt2] = get_tangents(c2, c3, r2, r3);
            d1 = point_to_segment(c1, lt1, lt2); d2 = point_to_segment(c1, rt1, rt2);
            if d1 > d2, line([lt1(1) lt2(1)], [lt1(2) lt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]);
            else line([rt1(1) rt2(1)], [rt1(2) rt2(2)], 'lineWidth', 2, 'color',  [0.6, 0.4, 0.8]); end
        end
    end
    for i = 1:length(poses{p}.centers)
        draw_circle(poses{p}.centers{i}(axis_indices), radii{i}, 'b');
        mypoint(poses{p}.centers{i}(axis_indices), 'b');
    end
end




