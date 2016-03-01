function [final_outline] = adjust_fingers_outline(centers, radii, final_outline, names_map)

%% Thumb outline
crop_indices_thumb = {[names_map('thumb_bottom'), names_map('thumb_middle')]};
limits_indices_thumb = {[names_map('thumb_bottom'), names_map('thumb_fold')]};
crop_outline_indices = [];
limits_outline_indices = [];
crop_indices_map = {};
limits_indices_map = {};
for i = 1:length(final_outline)
    for j = 1:length(crop_indices_thumb)
        %if all(ismember(final_outline{i}.indices, crop_indices_thumb{j}))
        if length(final_outline{i}.indices) == 2 && ...
               (final_outline{i}.indices(1) == crop_indices_thumb{j}(1) && final_outline{i}.indices(2) == crop_indices_thumb{j}(2) || ...
               final_outline{i}.indices(2) == crop_indices_thumb{j}(1) && final_outline{i}.indices(1) == crop_indices_thumb{j}(2))
            crop_outline_indices(end + 1) = i;
            crop_indices_map{end + 1} = crop_indices_thumb{j};
        end
    end
    for j = 1:length(limits_indices_thumb)
        %if all(ismember(final_outline{i}.indices, limits_indices_thumb{j}))
        if length(final_outline{i}.indices) == 2 && ...
               (final_outline{i}.indices(1) == limits_indices_thumb{j}(1) && final_outline{i}.indices(2) == limits_indices_thumb{j}(2) || ...
               final_outline{i}.indices(2) == limits_indices_thumb{j}(1) && final_outline{i}.indices(1) == limits_indices_thumb{j}(2))
            limits_outline_indices(end + 1) = i;
            limits_indices_map{end + 1} = limits_indices_thumb{j};
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
           
            %print_outline(final_outline(crop_outline_indices(i)));
            %print_outline(final_outline(limits_outline_indices(j)));
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
%print_outline(fingers_outline);

palm_outline = {};
for i = 1:length(limits_indices)
    [l1, l2, r1, r2] = get_tangents(centers{limits_indices{i}(1)}, centers{limits_indices{i}(2)}, radii{limits_indices{i}(1)}, radii{limits_indices{i}(2)});
    palm_outline{end + 1}.start = l1;
    palm_outline{end}.t1 = l1;
    palm_outline{end}.end = l2;
    palm_outline{end}.t2 = l2;
    palm_outline{end}.indices = limits_indices{i};
    palm_outline{end + 1}.start = r1;
    palm_outline{end}.t1 = r1;
    palm_outline{end}.end = r2;
    palm_outline{end}.t2 = r2;
    palm_outline{end}.indices = limits_indices{i};
end
%print_outline(palm_outline);

for i = 1:length(fingers_outline)
    for j = 1:length(palm_outline) 
        t = intersect_segment_segment(fingers_outline{i}.start, fingers_outline{i}.end, palm_outline{j}.start, palm_outline{j}.end);
        if ~isempty(t), 
            final_outline{end + 1} = crop_outline_segment(t, centers{fingers_outline{i}.indices(1)}, centers{fingers_outline{i}.indices(2)}, ...
                radii{fingers_outline{i}.indices(1)}, radii{fingers_outline{i}.indices(2)}, fingers_outline{i});
            %print_outline(final_outline(end));
        end
    end
end

%print_outline(final_outline);

% crop_outline_indices = [];
% limits_outline_indices = [];
% crop_indices_map = {};
% for i = 1:length(fingers_outline)
%     for j = 1:length(crop_indices)
%         if all(ismember(fingers_outline{i}.indices, crop_indices{j}))
%             crop_outline_indices(end + 1) = i;
%             crop_indices_map{end + 1} = crop_indices{j};
%         end
%     end
% end
% for i = 1:length(palm_outline)
%     for j = 1:length(limits_indices)
%         if all(ismember(palm_outline{i}.indices, limits_indices{j}))
%             limits_outline_indices(end + 1) = i;
%         end
%     end
% end
% 
% for i = 1:length(crop_outline_indices)
%     for j = 1:length(limits_outline_indices) 
%         t = intersect_segment_segment(fingers_outline{crop_outline_indices(i)}.start, fingers_outline{crop_outline_indices(i)}.end, ...
%             palm_outline{limits_outline_indices(j)}.start, palm_outline{limits_outline_indices(j)}.end);
%         if ~isempty(t), 
%             final_outline{end + 1} = crop_outline_segment(t, centers{crop_indices_map{i}(1)}, centers{crop_indices_map{i}(2)}, ...
%                 radii{crop_indices_map{i}(1)}, radii{crop_indices_map{i}(2)}, fingers_outline{crop_outline_indices(i)});
%         end
%     end
% end

end 

function print_outline(outline)
for i = 1:length(outline)
    disp(['outline[', num2str(i - 1), ']']);
    if length(outline{i}.indices) == 2
        disp(['   t1 = ' num2str(outline{i}.t1')]);
        disp(['   t2 = ' num2str(outline{i}.t2')]);
    end
    disp(['   indices = ' num2str(outline{i}.indices - 1)]);
    disp(['   start = ' num2str(outline{i}.start')]);
    disp(['   end = ' num2str(outline{i}.end')]);
    disp(' ');
end
end
