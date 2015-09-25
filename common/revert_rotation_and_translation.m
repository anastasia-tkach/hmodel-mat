function [points] = revert_rotation_and_translation(points, translation_vector, rotation_matrix, type)
 
if numel(points) == 3
    
    if strcmp(type, 'point')
        points = points - translation_vector;
    end
    points = rotation_matrix \ points;
else
    disp('Still to implement for many points')
end
