function [segments] = update_transform(segments, i)

if strcmp(segments{i}.name, 'empty'), return; end;

if segments{i}.parent_id ~= 0
    segments{i}.global = segments{segments{i}.parent_id}.global * segments{i}.local;
else
    segments{i}.global = segments{i}.local;
end

for c = segments{i}.children_ids
    segments = update_transform(segments, c);
end