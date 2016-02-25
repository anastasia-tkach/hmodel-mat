function [neighbors_list] = get_neighbors(b, block_indices, indices, neighbors_array)

if length(indices) == 1
    if indices(1) == block_indices(1), 
        count = 1; 
    else
        if indices(1) == block_indices(2),
            count = 2; 
        else
            count = 3;
        end
    end
end
if length(indices) == 2
    if indices(1) == block_indices(1)
        if indices(2) == block_indices(2), 
            count = 1; 
        else 
            count = 2; 
        end
    else
        count = 3;
    end
end

neighbors_list =  neighbors_array(6 * 6 * (b - 1) + 6 * (count - 1) + 1:6 * 6 * (b - 1) + 6 * (count - 1) + 6);