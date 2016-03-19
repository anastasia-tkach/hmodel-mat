function [] = print_blocks_names(blocks, names_map)

map_keys = keys(names_map);
map_values = values(names_map);
map_values = cell2mat(map_values);

for i = 1:length(blocks)
    s = [num2str(i - 1), ':'];
    for j = 1:length(blocks{i})
        index = find(map_values == blocks{i}(j));
        s = [s, ', ', map_keys{index}];
    end
    disp(s);
end