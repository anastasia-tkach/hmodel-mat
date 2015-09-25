function [adjucent_blocks_indices] = get_adjucent_blocks(index, current_block, blocks)

adjucent_blocks_indices = [];
for i = 1:length(index)
    for b = 1:length(blocks)
        if b == current_block, continue; end
        if ismember(index(i), blocks{b}) 
            adjucent_blocks_indices = [adjucent_blocks_indices, b];
        end
    end
end