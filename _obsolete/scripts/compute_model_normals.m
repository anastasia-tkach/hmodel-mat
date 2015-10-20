function [projections, normals] = compute_model_normals(centers, radii, blocks, points, normals, projections)



tangent_points = blocks_tangent_points(centers, blocks, radii);
normals = cell(length(points), 1);
tangent_point = [];
for i = 1:length(points)
    p = points{i};
    if length(indices{i}) == 1
        index = indices{i}(1);
        c1 = centers{index}; r1 = radii{index}; s = c1;
        q = c1 + r1 * (p - c1) / norm(p - c1);
    else
        if length(indices{i}) == 3
            for b = 1:length(blocks)
                if (length(blocks{b}) < 3), continue; end
                abs_index = [abs(indices{i}(1)), abs(indices{i}(2)), abs(indices{i}(3))];
                indicator = ismember(blocks{b}, abs_index);
                if sum(indicator) == 3
                    tangent_point = tangent_points{b};
                    break;
                end
            end
            indices{i} = abs_index;
        end
        [~, q, s, ~] = projection(p, indices{i}, radii, centers, tangent_point);
    end    
    normals{i} = (q - s) / norm(q - s);
    %mypoint(q, 'm'); mypoint(s, 'b'); myline(q, s, 'b');
end