function [final_outline] = adjust_fingers_outline(centers, radii, final_outline, names_map)

%% Thumb outline
crop_indices = {[names_map('thumb_bottom'), names_map('thumb_middle')]};
limits_indices = {[names_map('thumb_bottom'), names_map('thumb_fold')]};
crop_outline_indices = [];
limits_outline_indices = [];
crop_indices_map = {};
limits_indices_map = {};
for i = 1:length(final_outline)
    for j = 1:length(crop_indices)
        if all(ismember(final_outline{i}.indices, crop_indices{j}))
            crop_outline_indices(end + 1) = i;
            crop_indices_map{end + 1} = crop_indices{j};
        end
    end
    for j = 1:length(limits_indices)
        if all(ismember(final_outline{i}.indices, limits_indices{j}))
            limits_outline_indices(end + 1) = i;
            limits_indices_map{end + 1} = limits_indices{j};
        end
    end
end

for i = 1:length(crop_outline_indices)
    for j = 1:length(limits_outline_indices)
        t = intersect_segment_segment(final_outline{crop_outline_indices(i)}.start, final_outline{crop_outline_indices(i)}.end, ...
            final_outline{limits_outline_indices(j)}.start, final_outline{limits_outline_indices(j)}.end);
        if ~isempty(t), 
            final_outline{crop_outline_indices(i)} = crop_outline_segment(t, centers{crop_indices_map{i}(1)}, centers{crop_indices_map{i}(2)}, ...
                radii{crop_indices_map{i}(1)}, radii{crop_indices_map{i}(2)}, final_outline{crop_outline_indices(i)});
            final_outline{limits_outline_indices(j)} = crop_outline_segment(t, centers{limits_indices_map{j}(1)}, centers{limits_indices_map{j}(2)}, ...
                radii{limits_indices_map{j}(1)}, radii{limits_indices_map{j}(2)}, final_outline{limits_outline_indices(j)});
        end
    end
end

%% Fingers outline
crop_indices = {[names_map('pinky_base'), names_map('pinky_bottom')], [names_map('ring_base'), names_map('ring_bottom')], ...
    [names_map('middle_base'), names_map('middle_bottom')], [names_map('index_base'), names_map('index_bottom')],};
limits_indices = {[names_map('pinky_membrane'), names_map('ring_membrane')], [names_map('ring_membrane'), names_map('middle_membrane')], ...
    [names_map('middle_membrane'), names_map('index_membrane')]};
fingers_outline = {};
for i = 1:length(crop_indices)
    [l1, l2, r1, r2] = get_tangents(centers{crop_indices{i}(1)}, centers{crop_indices{i}(2)}, radii{crop_indices{i}(1)}, radii{crop_indices{i}(2)});
    fingers_outline{end + 1}.start = l1;
    fingers_outline{end}.t1 = l1;
    fingers_outline{end}.end = l2;
    fingers_outline{end}.t2 = l2;
    fingers_outline{end}.indices = crop_indices{i};
    fingers_outline{end + 1}.start = r1;
    fingers_outline{end}.t1 = r1;
    fingers_outline{end}.end = r2;
    fingers_outline{end}.t2 = r2;
    fingers_outline{end}.indices = crop_indices{i};
end
palm_outline = {};
for i = 1:length(limits_indices)
    [l1, l2, r1, r2] = get_tangents(centers{limits_indices{i}(1)}, centers{limits_indices{i}(2)}, radii{limits_indices{i}(1)}, radii{limits_indices{i}(2)});
    palm_outline{end + 1}.start = l1;
    palm_outline{end}.end = l2;
    palm_outline{end}.t2 = l2;
    palm_outline{end}.indices = limits_indices{i};
    palm_outline{end + 1}.start = r1;
    palm_outline{end}.t1 = r1;
    palm_outline{end}.end = r2;
    palm_outline{end}.t2 = r2;
    palm_outline{end}.indices = limits_indices{i};
end
crop_outline_indices = [];
limits_outline_indices = [];
crop_indices_map = {};
for i = 1:length(fingers_outline)
    for j = 1:length(crop_indices)
        if all(ismember(fingers_outline{i}.indices, crop_indices{j}))
            crop_outline_indices(end + 1) = i;
            crop_indices_map{end + 1} = crop_indices{j};
        end
    end
end
for i = 1:length(palm_outline)
    for j = 1:length(limits_indices)
        if all(ismember(palm_outline{i}.indices, limits_indices{j}))
            limits_outline_indices(end + 1) = i;
        end
    end
end

for i = 1:length(crop_outline_indices)
    for j = 1:length(limits_outline_indices) 
        t = intersect_segment_segment(fingers_outline{crop_outline_indices(i)}.start, fingers_outline{crop_outline_indices(i)}.end, ...
            palm_outline{limits_outline_indices(j)}.start, palm_outline{limits_outline_indices(j)}.end);
        if ~isempty(t), 
            final_outline{end + 1} = crop_outline_segment(t, centers{crop_indices_map{i}(1)}, centers{crop_indices_map{i}(2)}, ...
                radii{crop_indices_map{i}(1)}, radii{crop_indices_map{i}(2)}, fingers_outline{crop_outline_indices(i)});
        end
    end
end