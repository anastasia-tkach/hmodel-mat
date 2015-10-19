function [T] = pose(T, i, settings)

if T.parent_id(i) ~= 0
    T.frames{i} = T.frames{T.parent_id(i)};    
else
    T.frames{i} = makehgtform('translate', T.thetas(1:settings.num_translations));   
end
T.frames{i} = T.frames{i} * makehgtform('axisrotate', T.axis(i - 1,:), T.thetas(i - 1));
T.frames{i} = T.frames{i} * makehgtform('translate',  T.local_translation(i,:));
T.global_translation(i,:) = T.frames{i}(1:settings.num_translations, end);    

for c = T.children_ids{i}
    T = pose(T, c, settings);
end

