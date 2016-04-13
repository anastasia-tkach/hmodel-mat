clear; clc;

input_path = '_my_hand/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat'], 'blocks');

blocks = blocks(1:28);
palm_blocks = {
    [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_fold')], ...
    [names_map('palm_ring'), names_map('palm_pinky'), names_map('palm_right')], ...
    [names_map('palm_back'), names_map('palm_ring'), names_map('palm_right')], ...
    [names_map('palm_back'), names_map('palm_ring'), names_map('palm_middle')], ...
    [names_map('palm_back'), names_map('palm_left'), names_map('palm_middle')], ...
    [names_map('palm_left'), names_map('palm_middle'), names_map('palm_index')], ...
    [names_map('pinky_membrane'), names_map('palm_pinky'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('palm_pinky'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('middle_membrane'), names_map('ring_membrane')], ...
    [names_map('palm_ring'), names_map('palm_middle'), names_map('middle_membrane')], ...
    [names_map('palm_middle'), names_map('palm_index'), names_map('middle_membrane')], ...
    [names_map('palm_index'), names_map('index_membrane'), names_map('middle_membrane')], ...
    [names_map('thumb_base'), names_map('thumb_fold'), names_map('palm_thumb')]
    };

fingers_blocks{1} = {[names_map('pinky_middle'), names_map('pinky_top')], ...
    [names_map('pinky_bottom'), names_map('pinky_middle')], ...
    [names_map('pinky_base'), names_map('pinky_bottom')]};
fingers_blocks{2} = {[names_map('ring_top'), names_map('ring_middle')], ...
    [names_map('ring_bottom'), names_map('ring_middle')], ...
    [names_map('ring_bottom'), names_map('ring_base')]};
fingers_blocks{3} = {[names_map('middle_top'), names_map('middle_middle')], ...
    [names_map('middle_bottom'), names_map('middle_middle')], ...
    [names_map('middle_bottom'), names_map('middle_base')]};
fingers_blocks{4} = {[names_map('index_middle'), names_map('index_top')], ...
    [names_map('index_bottom'), names_map('index_middle')], ...
    [names_map('index_base'), names_map('index_bottom')]};
fingers_blocks{5} = {[names_map('thumb_top'), names_map('thumb_additional')], ...
    [names_map('thumb_top'), names_map('thumb_middle')], ...
    [names_map('thumb_bottom'), names_map('thumb_middle')]};

all_fingers_blocks = {};
for i = 1:length(fingers_blocks)
    for j = 1:length(fingers_blocks{i})
        all_fingers_blocks{end + 1} = fingers_blocks{i}{j};
    end
end

fingers_blocks_indices = zeros(0, 1);
for i = 1:length(all_fingers_blocks)
    current_indices = all_fingers_blocks{i};
    for index = 1:length(blocks)
        block_indices = blocks{index};
        if length(current_indices) ~= length(block_indices), continue; end       
        if all(ismember(current_indices, block_indices))
            fingers_blocks_indices{end + 1} = index;
            break;
        end
    end
end
palm_blocks_indices = zeros(0, 1);
for i = 1:length(palm_blocks)
    current_indices = palm_blocks{i};
    for index = 1:length(blocks)
        block_indices = blocks{index};
        if length(current_indices) ~= length(block_indices), continue; end       
        if all(ismember(current_indices, block_indices))
            palm_blocks_indices{end + 1} = index;
            break;
        end
    end
end

neighbors = cell(length(blocks), 1);
for i = 1:length(all_fingers_blocks)    
    for j = 1:length(all_fingers_blocks)
       if any(ismember(all_fingers_blocks{i}, all_fingers_blocks{j}))
           neighbors{i} = [neighbors{i}, fingers_blocks_indices(j)];
       end
    end
    for j = 1:length(palm_blocks)
       if any(ismember(all_fingers_blocks{i}, palm_blocks{j}))
           neighbors{i} = [neighbors{i}, palm_blocks_indices(j)];
       end
    end
end
