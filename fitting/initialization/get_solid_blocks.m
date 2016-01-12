function [solid_blocks] = get_solid_blocks(blocks, names_map, named_blocks, named_solid_blocks, named_elastic_blocks, named_phantom_blocks)

%% Solid blocks
solid_blocks_indices = cell(length(named_solid_blocks), 1);
solid_indicator = zeros(length(blocks), 1);
for i = 1:length(named_solid_blocks)
    solid_blocks_indices{i} = [];
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
                solid_blocks_indices{i} = [solid_blocks_indices{i}, index];
                solid_indicator(index) = 1;
                break;
            end
            
        end
        
    end
end

%% Elastic blocks
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
            solid_indicator(index) = -1;
            break;
        end        
    end    
end

%% Merge solid and elastic blocks
single_solid_blocks_indices = {};
for i = 1:length(solid_indicator)
    if solid_indicator(i) == 0
        single_solid_blocks_indices = [single_solid_blocks_indices, {i}];
    end
end
solid_blocks_indices = [single_solid_blocks_indices'; solid_blocks_indices];

solid_blocks = cell(length(solid_blocks_indices), 1);
for i = 1:length(solid_blocks_indices)
    solid_blocks{i} = [];
    for j = 1:length(solid_blocks_indices{i})
        solid_blocks{i} = [solid_blocks{i}, blocks{solid_blocks_indices{i}(j)}];
    end
    solid_blocks{i} = unique(solid_blocks{i});
end

%% Get phantom blocks
phantom_blocks = cell(length(named_phantom_blocks), 1);
for i = 1:length(named_phantom_blocks)    
    for j = 1:length(named_phantom_blocks{i})    
        key = named_phantom_blocks{i}(j);
        phantom_blocks{i} = [phantom_blocks{i}, names_map(key{1})];
    end
end


%% Merge solid and phantom blocks
solid_blocks = [solid_blocks; phantom_blocks];
