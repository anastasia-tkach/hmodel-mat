function [special_blocks_indices] = get_special_blocks_indices(named_blocks, named_special_blocks)

special_blocks_indices = zeros(0, 1);
for i = 1:length(named_special_blocks)
    current_name = sort(named_special_blocks{i});
    for index = 1:length(named_blocks)
        block_name = sort(named_blocks{index});
        if length(current_name) ~= length(block_name), continue; end
        is_equal = true;
        for k = 1:length(current_name)
            if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
        end
        if is_equal == true
            special_blocks_indices(end + 1) = index;
            break;
        end
    end
end

