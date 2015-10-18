function [a] = extractfield(structures, field_name)

a = zeros(length(structures), 1);
for i = 1:length(structures)
    a(i) = getfield(structures{i}, field_name);
end