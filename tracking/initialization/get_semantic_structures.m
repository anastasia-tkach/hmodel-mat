function [attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks)

%% Get named blocks
SEMANTICS;

%% Describe attachments
attachments = cell(length(centers), 1);
for key = keys(names_map)
    key = key{1};
    index = names_map(key);
    if ~isKey(attachments_map, key), continue; end
    
    attachment_name = sort(attachments_map(key));
    for i = 1:length(named_blocks)
        block_name = sort(named_blocks{i});
        if length(attachment_name) ~= length(block_name), continue; end
        is_equal = true;
        for j = 1:length(attachment_name)
            if ~strcmp(attachment_name{j}, block_name{j}), is_equal = false; end
        end
        if is_equal == true
            attachments{index}.block_index = i;
            break;
        end
    end
end


%% Global frame indices
current_name = sort(named_global_frame_block);
for index = 1:length(named_blocks)
    block_name = sort(named_blocks{index});
    if length(current_name) ~= length(block_name), continue; end
    is_equal = true;
    for k = 1:length(current_name)
        if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
    end
    if is_equal == true
        global_frame_block = index;
        global_frame_indices = blocks{index};
        break;
    end
    
end

%% Describe parents
parents = cell(length(blocks), 1);

for key = keys(parents_map)
    key = key{1};
    child_name = sort(strsplit(key));
    parent_name = sort(parents_map(key));
    
    for index = 1:length(named_blocks)
        block_name = sort(named_blocks{index});
        
        %% Find child block
        if length(child_name) == length(block_name)
            is_equal = true;
            for j = 1:length(child_name)
                if ~strcmp(child_name{j}, block_name{j})
                    is_equal = false;
                end
            end
            if is_equal, child_index = index; end
        end
        
        %% Find parent block
        if length(parent_name) == length(block_name)
            is_equal = true;
            for j = 1:length(parent_name)
                if ~strcmp(parent_name{j}, block_name{j})
                    is_equal = false;
                end
            end
            if is_equal, parent_index = index; end
        end
    end
    
    parents{child_index} = parent_index;
end

%% Solid blocks
solid_blocks = cell(length(named_solid_blocks), 1);
solid_indicator = zeros(length(blocks), 1);
for i = 1:length(named_solid_blocks)
    solid_blocks{i} = [];
    for j = 1:length(named_solid_blocks{i})
        current_name = sort(named_solid_blocks{i}{j});
        
        for index = 1:length(named_blocks)
            block_name = sort(named_blocks{index});
            if length(current_name) ~= length(block_name), continue; end
            is_equal = true;
            for k = 1:length(current_name)
                if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
            end
            if is_equal == true
                solid_blocks{i} = [solid_blocks{i}, index];
                solid_indicator(index) = 1;
                break;
            end
            
        end
        
    end
end


%% Elastic blocks
elastic_blocks = zeros(length(named_elastic_blocks), 1);
solid_indicator = zeros(length(elastic_blocks), 1);
for i = 1:length(named_elastic_blocks)
    
    current_name = sort(named_elastic_blocks{i});
    
    for index = 1:length(named_blocks)
        block_name = sort(named_blocks{index});
        if length(current_name) ~= length(block_name), continue; end
        is_equal = true;
        for k = 1:length(current_name)
            if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
        end
        if is_equal == true
            elastic_blocks(i) = index;
            solid_indicator(index) = -1;
            break;
        end        
    end    
end

