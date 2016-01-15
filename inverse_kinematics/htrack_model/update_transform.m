function [segments] = update_transform(segments, i)

if strcmp(segments{i}.name, 'empty'), return; end;

if ~isempty(segments{i}.parent_id)
    segments{i}.global = segments{segments{i}.parent_id}.global * segments{i}.local;
else
    segments{i}.global = segments{i}.local;
end

for c = segments{i}.children_ids
    segments = update_transform(segments, c);
end